import font_to_svg
import firebase_storage


def main():
    font_names = font_to_svg.get_file_names("fonts/")
    svgs = font_to_svg.font_to_svg(font_names, "eko")
    font_to_svg.svgs_to_file(svgs, "svgs")

    firebase_storage.upload_files_from_directory("svgs", "eko_logos")


if __name__ == "__main__":
    main()
