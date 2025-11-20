package VerifyUsers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strings"

	"golang.org/x/net/html"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/cloudevents/sdk-go/v2/event"
)

func init() {
	functions.CloudEvent("VerifyUsers", VerifyUsers)
}

// VerifyUsers is a scheduled function that runs daily at midnight.
func VerifyUsers(ctx context.Context, e event.Event) error {
	log.Println("VerifyUsers task started - running daily verification.")
	run()
	log.Println("VerifyUsers task completed successfully.")
	return nil
}

type User struct {
	UID             string `firestore:"-"`
	Username        string `firestore:"username"`
	VerificationURL string `firestore:"verificationUrl"`
}

func fetchPage(url string) (*http.Response, error) {
	if !strings.HasPrefix(url, "http://") && !strings.HasPrefix(url, "https://") {
		url = "https://" + url
	}
	response, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("error making GET request: %w", err)
	}

	if response.StatusCode != http.StatusOK {
		response.Body.Close() // Close the body on non-200 status
		return nil, fmt.Errorf("received non-200 status code: %d", response.StatusCode)
	}

	return response, nil
}

func findAllRelMeLinks(n *html.Node) []string {
	var foundURLs []string

	if n.Type == html.ElementNode && (n.Data == "link" || n.Data == "a") {
		var isRelMe bool
		var href string
		for _, attr := range n.Attr {
			if attr.Key == "rel" {
				rels := strings.FieldsSeq(attr.Val)
				for rel := range rels {
					if rel == "me" {
						isRelMe = true
						break
					}
				}
			}
			if attr.Key == "href" {
				href = attr.Val
			}
		}
		if isRelMe && href != "" {
			foundURLs = append(foundURLs, href)
		}
	}

	for c := n.FirstChild; c != nil; c = c.NextSibling {
		foundURLs = append(foundURLs, findAllRelMeLinks(c)...)
	}

	return foundURLs
}

func queryUnverifiedUsers(ctx context.Context, client *firestore.Client) ([]User, error) {
	iter := client.Collection("users").
		Where("verificationUrl", "!=", nil).
		Where("isVerified", "==", nil).
		Documents(ctx)

	docs, err := iter.GetAll()
	if err != nil {
		return nil, fmt.Errorf("error getting unverified users: %w", err)
	}

	if len(docs) == 0 {
		return []User{}, nil
	}

	var users []User
	for _, doc := range docs {
		var user User
		if err := doc.DataTo(&user); err != nil {
			return nil, fmt.Errorf("error converting user data: %w", err)
		}
		user.UID = doc.Ref.ID
		users = append(users, user)
	}

	return users, nil
}

func run() {
	ctx := context.Background()
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	client, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalln(err)
	}
	defer client.Close()

	// Query unverified users
	users, err := queryUnverifiedUsers(ctx, client)
	if err != nil {
		log.Fatalf("Error querying unverified users: %v", err)
	}

	for _, user := range users {
		url := user.VerificationURL
		resp, err := fetchPage(url)
		if err != nil {
			log.Fatalf("Fatal Error: %v\n", err)
		}
		defer resp.Body.Close()

		doc, err := html.Parse(resp.Body)
		if err != nil {
			log.Fatalf("!!! Error parsing HTML: %v\n", err)
		}
		foundURLs := findAllRelMeLinks(doc)

		for _, url := range foundURLs {
			if strings.Contains(url, "app.eko-app.com") && strings.Contains(url, user.Username) {
				_, err := client.Collection("users").Doc(user.UID).Set(ctx, map[string]any{
					"isVerified": true,
					"verifiedAt": firestore.ServerTimestamp,
				}, firestore.MergeAll)
				if err != nil {
					log.Printf("Failed to update user %s: %v", user.UID, err)
				}
			}
		}

	}
}
