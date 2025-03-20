package CreateImage

import (
	"io"
	"net/http"
	"os"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/TheZoraiz/ascii-image-converter/aic_package"
)

func init() {
	functions.HTTP("HelloHTTP", CreateImage)
}

func convert(file io.Reader) (string, error) {
	flags := aic_package.DefaultFlags()
	flags.Dimensions = []int{150, 75}

	// Create a temporary file to hold the uploaded image.
	tempFile, err := os.CreateTemp("", "upload-*")
	if err != nil {
		return "", err
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	// Copy the image data into the temporary file.
	if _, err := io.Copy(tempFile, file); err != nil {
		return "", err
	}

	// Pass the temporary file's path to the conversion function.
	asciiArt, err := aic_package.Convert(tempFile.Name(), flags)
	if err != nil {
		return "", err
	}
	return asciiArt, nil
}

func CreateImage(w http.ResponseWriter, r *http.Request) {

	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Error parsing multipart form: "+err.Error(), http.StatusBadRequest)
		return
	}

	file, _, err := r.FormFile("image")
	if err != nil {
		http.Error(w, "Error retrieving the file: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	asciiArt, err := convert(file)
	if err != nil {
		http.Error(w, "Error converting image: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte(asciiArt))
}
