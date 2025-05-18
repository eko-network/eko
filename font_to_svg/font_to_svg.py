# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "ziafont",
# ]
# ///
import os
import ziafont
from typing import Dict, List

ziafont.config.svg2 = False


def get_file_names(folder_path: str) -> List[str]:
    try:
        entries = os.listdir(folder_path)
        files = []
        for entry in entries:
            filename = os.path.join(folder_path, entry)
            if os.path.isfile(filename) and ".ttf" in filename:
                files.append(filename)
        return files
    except FileNotFoundError:
        print(f"Folder not found: {folder_path}")
        return []
    except Exception as e:
        print(f"An error occurred: {e}")
        return []


def font_to_svg(fonts: List[str], text: str) -> dict:
    svgs = dict()
    for fontname in fonts:
        print("reading", fontname)
        font = ziafont.Font(fontname)
        svgs[fontname.split("/", 1)[1].split(".", 1)[0]] = font.text(text).svg()
    return svgs


def svgs_to_file(svgs: dict, folder_path: str):
    if os.path.exists(folder_path):
        if not os.path.isdir(folder_path):
            raise NotADirectoryError(f"'{folder_path}' exists and is not a directory.")
    else:
        os.makedirs(folder_path)

    for name, svg in svgs.items():
        with open(os.path.join(folder_path, f"{name}.svg"), "w") as f:
            f.write(svg)


if __name__ == "__main__":
    font_names = get_file_names("fonts/")
    svgs = font_to_svg(font_names, "eko")
    svgs_to_file(svgs, "svgs")
