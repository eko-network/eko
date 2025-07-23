

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF p_is_liking THEN
    -- Try to update the row
INSERT INTO public.comment_likes (user_uid, comment_id, is_dislike)
    VALUES (v_uid, p_id, p_is_dislike)
    ON CONFLICT (user_uid, comment_id)
    DO UPDATE SET is_dislike = EXCLUDED.is_dislike;
  ELSE
    -- Delete the like if unliking
    DELETE FROM public.comment_likes AS p
    WHERE p.comment_id = p_id AND p.user_uid = v_uid;
  END IF;
END;
$$;


ALTER FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF p_is_liking THEN
    -- Try to update the row
INSERT INTO public.post_likes (user_uid, post_id, is_dislike)
    VALUES (v_uid, p_id, p_is_dislike)
    ON CONFLICT (user_uid, post_id)
    DO UPDATE SET is_dislike = EXCLUDED.is_dislike;
  ELSE
    -- Delete the like if unliking
    DELETE FROM public.post_likes AS p
    WHERE p.post_id = p_id AND p.user_uid = v_uid;
  END IF;
END;
$$;


ALTER FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_chamber_by_id"("p_uid" bigint) RETURNS TABLE("id" bigint, "name" "text", "description" "text", "icon" "text", "latest_post_time" timestamp with time zone)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.name, c.description, c.icon, c.latest_post_time
    FROM public.full_chamber_info c
    WHERE c.id = p_uid
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_chamber_by_id"("p_uid" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_comment_by_id"("p_id" bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "body" "text", "gif" "text", "like_count" bigint, "dislike_count" bigint, "parent_post_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_comment_info as p
    WHERE p.id = p_id
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_comment_by_id"("p_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_follow_info"("p_uid" "uuid") RETURNS TABLE("following" bigint, "followers" bigint)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM public.following f WHERE f.source_uid = p_uid) AS following,
        (SELECT COUNT(*) FROM public.following f WHERE f.target_uid = p_uid) AS followers;
END;
$$;


ALTER FUNCTION "public"."get_follow_info"("p_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_post_by_id"("p_id" bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_post_info as p
    WHERE p.id = p_id
    
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_post_by_id"("p_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_by_id"("p_uid" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
    FROM public.users u
    WHERE u.id = p_uid 
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
        )
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_user_by_id"("p_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_public_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.usernames (user_uid, username)
  values (new.id, new.username);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_public_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.users (id, username, created_at, profile_picture, birthday, name, firebase_uid, bio, is_verified)
  values (new.id, new.raw_user_meta_data ->> 'username', COALESCE(NEW.raw_user_meta_data ->> 'created_at', now()::text)::timestamp, NEW.raw_user_meta_data ->> 'profile_picture', (NEW.raw_user_meta_data ->> 'birthday')::date, NEW.raw_user_meta_data ->> 'name', NEW.raw_user_meta_data ->> 'firebase_uid', NEW.raw_user_meta_data ->> 'bio', (NEW.raw_user_meta_data ->> 'is_verified')::boolean);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_chamber_id" bigint) RETURNS TABLE("success" boolean, "error_message" "text", "post_id" bigint)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
    new_post_id BIGINT;
BEGIN
    BEGIN
        INSERT INTO public.posts (
            created_at,
            firebase_uid,
            body,
            title,
            gif,
            poll,
            author_uid,
            image,
            chamber_id
        ) VALUES (
            p_created_at,
            p_firebase_uid,
            p_body,
            p_title,
            p_gif,
            p_poll,
            p_author_uid,
            CASE 
                WHEN p_image_base64 IS NOT NULL THEN decode(p_image_base64, 'base64')
                ELSE NULL
            END,
            p_chamber_id
        ) RETURNING id INTO new_post_id;
        
        RETURN QUERY SELECT TRUE, NULL::TEXT, new_post_id;
        
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM, NULL::BIGINT;
    END;
END;
$$;


ALTER FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_chamber_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_username_available"("p_username" "text") RETURNS boolean
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$
BEGIN
  -- If there is no such username, it is available
  RETURN NOT EXISTS (
    SELECT 1
    FROM public.usernames
    WHERE username = p_username
  );
END;
$$;


ALTER FUNCTION "public"."is_username_available"("p_username" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_chamber_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_chamber_id" bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_post_info as p
    WHERE 
        p.chamber_id = p_chamber_id
    --paging
        AND (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
    ORDER BY p.created_at DESC, p.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_chamber_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_chamber_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_chambers"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "created_at" timestamp with time zone, "name" "text", "description" "text", "icon" "text", "latest_post_time" timestamp with time zone)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_chamber_info as c
    WHERE (p_last_id IS NULL OR (c.latest_post_time, c.id) < (p_last_time, p_last_id))
    ORDER BY c.latest_post_time DESC, c.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_chambers"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "body" "text", "gif" "text", "like_count" bigint, "dislike_count" bigint, "parent_post_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_comment_info as p
    WHERE
        p.parent_post_id = p_parent_post_id
    --paging
        AND (p_last_time IS NULL OR (p.created_at, p.id) > (p_last_time, p_last_id))
    ORDER BY p.created_at ASC, p.id ASC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  RETURN QUERY
  WITH followed AS (
    SELECT target_uid FROM public.following WHERE source_uid = v_uid
  ),
  filtered_posts AS (
    SELECT * FROM public.full_post_info p
    WHERE (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
  ),
  from_followed AS (
    SELECT p.*
    FROM filtered_posts p
    JOIN followed f ON p.author_uid = f.target_uid
  ),
  from_chambers AS (
    SELECT p.*
    FROM filtered_posts p
    LEFT JOIN followed f ON p.author_uid = f.target_uid
    WHERE p.chamber_id IS NOT NULL AND f.target_uid IS NULL
  )
  SELECT * FROM (
    SELECT * FROM from_followed
    UNION ALL
    SELECT * FROM from_chambers
  ) AS combined
  ORDER BY created_at DESC, id DESC
  LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_post_info as p
    WHERE 
    --public
        p.chamber_id is NULL
    --paging
        AND (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
    ORDER BY p.created_at DESC, p.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint DEFAULT NULL::bigint, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_post_info as p
    WHERE (p_last_likes IS NULL OR (p.like_count, p.id) < (p_last_likes, p_last_id)) AND p.chamber_id is NULL
    ORDER BY p.like_count DESC, p.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_user_uid" "uuid") RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "is_eko" boolean, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "chamber_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_post_info as p
    WHERE 
    --author
        p_user_uid = p.author_uid
    --paging
        AND (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
    ORDER BY p.created_at DESC, p.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_user_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean, "similarity" real)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, GREATEST(extensions.similarity(u.username, p_search), extensions.similarity(u.name, p_search)) AS similarity
    FROM public.users u
    WHERE 
    --paging
    (p_last_similarity is NULL or (GREATEST(extensions.similarity(u.username, p_search), extensions.similarity(u.name, p_search)), u.id) < (p_last_similarity, p_last_uid))

    --exclusion
    AND (NOT p_exclude_current_user OR u.id <> auth.uid())
    -- blocking
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
        )
    ORDER BY GREATEST(extensions.similarity(u.username ,p_search), extensions.similarity(u.name, p_search)) DESC, u.id DESC

    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."activity" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type" integer NOT NULL,
    "source_uid" "uuid" DEFAULT "auth"."uid"(),
    "target_uid" "uuid",
    "chamber_id" bigint,
    "post_id" bigint
);


ALTER TABLE "public"."activity" OWNER TO "postgres";


ALTER TABLE "public"."activity" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."activity_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."blocked" (
    "source_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "target_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."blocked" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chamber_members" (
    "user_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."chamber_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chambers" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "firebase_uid" "text",
    "name" "text" NOT NULL,
    "description" "text",
    "icon" "text"
);


ALTER TABLE "public"."chambers" OWNER TO "postgres";


ALTER TABLE "public"."chambers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."chambers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."comment_likes" (
    "user_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "comment_id" bigint NOT NULL,
    "is_dislike" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."comment_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "author_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "body" "text",
    "gif" "text",
    "parent_post_id" bigint NOT NULL,
    "firebase_uid" "text"
);


ALTER TABLE "public"."comments" OWNER TO "postgres";


ALTER TABLE "public"."comments" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."comments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."fcm_tockens" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "token" "text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."fcm_tockens" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."following" (
    "source_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "target_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."following" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "author_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "title" "text",
    "body" "text",
    "gif" "text",
    "image" "bytea",
    "poll" "text"[],
    "ekoed_id" bigint,
    "chamber_id" bigint,
    "is_eko" boolean DEFAULT false NOT NULL,
    "firebase_uid" "text"
);


ALTER TABLE "public"."posts" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_chamber_info" WITH ("security_invoker"='on') AS
 SELECT "id",
    "created_at",
    "name",
    "description",
    "icon",
    COALESCE(( SELECT "max"("p"."created_at") AS "max"
           FROM "public"."posts" "p"
          WHERE ("p"."chamber_id" = "g"."id")), "created_at") AS "latest_post_time"
   FROM "public"."chambers" "g";


ALTER VIEW "public"."full_chamber_info" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_comment_info" WITH ("security_invoker"='on') AS
 SELECT "p"."id",
    "p"."author_uid",
    "p"."created_at",
    "p"."body",
    "p"."gif",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."is_dislike" = false))) AS "like_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."is_dislike" = true))) AS "dislike_count",
    "p"."parent_post_id",
    (EXISTS ( SELECT 1
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = false)))) AS "is_liked",
    (EXISTS ( SELECT 1
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = true)))) AS "is_disliked"
   FROM "public"."comments" "p",
    LATERAL ( SELECT "auth"."uid"() AS "uid") "u";


ALTER VIEW "public"."full_comment_info" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."post_likes" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "post_id" bigint NOT NULL,
    "is_dislike" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."post_likes" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_post_info" WITH ("security_invoker"='on') AS
 SELECT "p"."id",
    "p"."author_uid",
    "p"."created_at",
    "p"."title",
    "p"."body",
    "p"."gif",
    "regexp_replace"("encode"("p"."image", 'base64'::"text"), '
'::"text", ''::"text", 'g'::"text") AS "image",
    "p"."ekoed_id",
    "p"."is_eko",
    ( SELECT "count"(*) AS "count"
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."is_dislike" = false))) AS "like_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."is_dislike" = true))) AS "dislike_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comments" "c"
          WHERE ("c"."parent_post_id" = "p"."id")) AS "comment_count",
    "p"."chamber_id",
    (EXISTS ( SELECT 1
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = false)))) AS "is_liked",
    (EXISTS ( SELECT 1
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = true)))) AS "is_disliked"
   FROM "public"."posts" "p",
    LATERAL ( SELECT "auth"."uid"() AS "uid") "u";


ALTER VIEW "public"."full_post_info" OWNER TO "postgres";


ALTER TABLE "public"."posts" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."posts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "source_uid" "uuid" DEFAULT "auth"."uid"(),
    "target_uid" "uuid",
    "post_id" bigint,
    "message" "text" NOT NULL
);


ALTER TABLE "public"."reports" OWNER TO "postgres";


ALTER TABLE "public"."reports" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."reports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."user_group_ids" AS
 SELECT DISTINCT "group_id"
   FROM "public"."chamber_members"
  WHERE ("user_uid" = ( SELECT "auth"."uid"() AS "uid"));


ALTER VIEW "public"."user_group_ids" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."usernames" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "username" "text" NOT NULL
);


ALTER TABLE "public"."usernames" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "profile_picture" "text",
    "birthday" "date",
    "name" "text",
    "username" "text" NOT NULL,
    "firebase_uid" "text",
    "is_verified" boolean DEFAULT false,
    "bio" "text"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."utilities" (
    "platform" "text" NOT NULL,
    "minimum_version" "text" NOT NULL
);


ALTER TABLE "public"."utilities" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_pkey" PRIMARY KEY ("source_uid", "target_uid");



ALTER TABLE ONLY "public"."chamber_members"
    ADD CONSTRAINT "chamber_members_pkey" PRIMARY KEY ("user_uid", "group_id");



ALTER TABLE ONLY "public"."chambers"
    ADD CONSTRAINT "chambers_firebase_id_key" UNIQUE ("firebase_uid");



ALTER TABLE ONLY "public"."chambers"
    ADD CONSTRAINT "chambers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_pkey" PRIMARY KEY ("user_uid", "comment_id");



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."fcm_tockens"
    ADD CONSTRAINT "fcm_tockens_pkey" PRIMARY KEY ("user_uid", "token");



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_pkey" PRIMARY KEY ("source_uid", "target_uid");



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_pkey" PRIMARY KEY ("user_uid", "post_id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_pkey" PRIMARY KEY ("user_uid");



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."utilities"
    ADD CONSTRAINT "utilities_pkey" PRIMARY KEY ("platform");



CREATE INDEX "posts_created_at_id_desc_idx" ON "public"."posts" USING "btree" ("created_at" DESC, "id" DESC);



CREATE INDEX "users_name_trgm_idx" ON "public"."users" USING "gin" ("name" "extensions"."gin_trgm_ops");



CREATE INDEX "users_username_trgm_idx" ON "public"."users" USING "gin" ("username" "extensions"."gin_trgm_ops");



CREATE OR REPLACE TRIGGER "on_public_user_created" AFTER INSERT ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_public_user"();



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_chamber_id_fkey" FOREIGN KEY ("chamber_id") REFERENCES "public"."chambers"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chamber_members"
    ADD CONSTRAINT "chamber_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."chambers"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chamber_members"
    ADD CONSTRAINT "chamber_members_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_comment_fkey" FOREIGN KEY ("comment_id") REFERENCES "public"."comments"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_user_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_author_uid_fkey" FOREIGN KEY ("author_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_parent_post_id_fkey" FOREIGN KEY ("parent_post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."fcm_tockens"
    ADD CONSTRAINT "fcm_tockens_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_post_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_user_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_author_fkey" FOREIGN KEY ("author_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_chamber_id_fkey" FOREIGN KEY ("chamber_id") REFERENCES "public"."chambers"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_ekoed_id_fkey" FOREIGN KEY ("ekoed_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_username_fkey" FOREIGN KEY ("username") REFERENCES "public"."users"("username") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow blocking users" ON "public"."blocked" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "Enable delete for users based on user_id" ON "public"."post_likes" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable insert for authenticated users only" ON "public"."reports" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Enable insert for users based on user_id" ON "public"."comments" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "author_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."post_likes" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."users" FOR UPDATE TO "authenticated" USING (true) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable read access for all users" ON "public"."activity" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."usernames" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."utilities" FOR SELECT USING (true);



CREATE POLICY "Enable read to authenticated when not blocked and in group" ON "public"."posts" FOR SELECT TO "authenticated" USING (((NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE ((("b"."source_uid" = ( SELECT "auth"."uid"() AS "uid")) AND ("b"."target_uid" = "posts"."author_uid")) OR (("b"."source_uid" = "posts"."author_uid") AND ("b"."target_uid" = ( SELECT "auth"."uid"() AS "uid"))))))) AND (("chamber_id" IS NULL) OR (EXISTS ( SELECT 1
   FROM "public"."chamber_members" "c"
  WHERE (("c"."group_id" = "posts"."chamber_id") AND ("c"."user_uid" = ( SELECT "auth"."uid"() AS "uid"))))))));



CREATE POLICY "Enable update for users based on uid" ON "public"."post_likes" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "FIXME: view who is in groups you are in" ON "public"."chamber_members" FOR SELECT TO "authenticated" USING (("group_id" IN ( SELECT "user_group_ids"."group_id"
   FROM "public"."user_group_ids")));



ALTER TABLE "public"."activity" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "allow ead comments if they can read post" ON "public"."comments" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "comments"."parent_post_id"))));



CREATE POLICY "block filter" ON "public"."following" FOR SELECT TO "authenticated" USING (((NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE (("b"."target_uid" = ( SELECT "auth"."uid"() AS "uid")) AND (("b"."source_uid" = "following"."source_uid") OR ("b"."source_uid" = "following"."target_uid")))))) AND (NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE (("b"."source_uid" = ( SELECT "auth"."uid"() AS "uid")) AND (("b"."target_uid" = "following"."source_uid") OR ("b"."target_uid" = "following"."target_uid"))))))));



ALTER TABLE "public"."blocked" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chamber_members" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chambers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."comment_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "delete based on uid" ON "public"."comment_likes" FOR DELETE TO "authenticated" USING (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."fcm_tockens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."following" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "insert comment likes" ON "public"."comment_likes" FOR INSERT TO "authenticated" WITH CHECK (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "insert follows where you are source" ON "public"."following" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "only have access to you own tokens" ON "public"."fcm_tockens" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "only view groups you are in" ON "public"."chambers" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."chamber_members" "c"
  WHERE (("c"."group_id" = "chambers"."id") AND ("c"."user_uid" = ( SELECT "auth"."uid"() AS "uid"))))));



ALTER TABLE "public"."post_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."posts" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "read comment likes if you can read comment" ON "public"."comment_likes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."comments" "c"
  WHERE ("c"."id" = "comment_likes"."comment_id"))));



CREATE POLICY "removed anything related to you" ON "public"."following" FOR DELETE TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "source_uid") OR (( SELECT "auth"."uid"() AS "uid") = "target_uid")));



ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "see who you have blocked" ON "public"."blocked" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "unblock people" ON "public"."blocked" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "update based on uid" ON "public"."comment_likes" FOR UPDATE TO "authenticated" USING (("user_uid" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "user can read like if they can read post" ON "public"."post_likes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "post_likes"."post_id"))));



ALTER TABLE "public"."usernames" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."utilities" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































































































































GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_chamber_by_id"("p_uid" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_chamber_by_id"("p_uid" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_chamber_by_id"("p_uid" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_chamber_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_chamber_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_chamber_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_chamber_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_chamber_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_chamber_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_chamber_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_chamber_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_chamber_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_chambers"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_chambers"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_chambers"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_user_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_user_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint, "p_user_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "service_role";


















GRANT ALL ON TABLE "public"."activity" TO "anon";
GRANT ALL ON TABLE "public"."activity" TO "authenticated";
GRANT ALL ON TABLE "public"."activity" TO "service_role";



GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."blocked" TO "anon";
GRANT ALL ON TABLE "public"."blocked" TO "authenticated";
GRANT ALL ON TABLE "public"."blocked" TO "service_role";



GRANT ALL ON TABLE "public"."chamber_members" TO "anon";
GRANT ALL ON TABLE "public"."chamber_members" TO "authenticated";
GRANT ALL ON TABLE "public"."chamber_members" TO "service_role";



GRANT ALL ON TABLE "public"."chambers" TO "anon";
GRANT ALL ON TABLE "public"."chambers" TO "authenticated";
GRANT ALL ON TABLE "public"."chambers" TO "service_role";



GRANT ALL ON SEQUENCE "public"."chambers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."chambers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."chambers_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."comment_likes" TO "anon";
GRANT ALL ON TABLE "public"."comment_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."comment_likes" TO "service_role";



GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."fcm_tockens" TO "anon";
GRANT ALL ON TABLE "public"."fcm_tockens" TO "authenticated";
GRANT ALL ON TABLE "public"."fcm_tockens" TO "service_role";



GRANT ALL ON TABLE "public"."following" TO "anon";
GRANT ALL ON TABLE "public"."following" TO "authenticated";
GRANT ALL ON TABLE "public"."following" TO "service_role";



GRANT ALL ON TABLE "public"."posts" TO "anon";
GRANT ALL ON TABLE "public"."posts" TO "authenticated";
GRANT ALL ON TABLE "public"."posts" TO "service_role";



GRANT ALL ON TABLE "public"."full_chamber_info" TO "anon";
GRANT ALL ON TABLE "public"."full_chamber_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_chamber_info" TO "service_role";



GRANT ALL ON TABLE "public"."full_comment_info" TO "anon";
GRANT ALL ON TABLE "public"."full_comment_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_comment_info" TO "service_role";



GRANT ALL ON TABLE "public"."post_likes" TO "anon";
GRANT ALL ON TABLE "public"."post_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."post_likes" TO "service_role";



GRANT ALL ON TABLE "public"."full_post_info" TO "anon";
GRANT ALL ON TABLE "public"."full_post_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_post_info" TO "service_role";



GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";



GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_group_ids" TO "anon";
GRANT ALL ON TABLE "public"."user_group_ids" TO "authenticated";
GRANT ALL ON TABLE "public"."user_group_ids" TO "service_role";



GRANT ALL ON TABLE "public"."usernames" TO "anon";
GRANT ALL ON TABLE "public"."usernames" TO "authenticated";
GRANT ALL ON TABLE "public"."usernames" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."utilities" TO "anon";
GRANT ALL ON TABLE "public"."utilities" TO "authenticated";
GRANT ALL ON TABLE "public"."utilities" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
