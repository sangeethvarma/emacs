#!python
import io
import os
import sys

import pyperclip
import pytesseract
from PIL import Image, ImageGrab

pytesseract.pytesseract.tesseract_cmd = "C:\\Users\\Sangeeth\\scoop\\apps\\tesseract\\current\\tesseract.exe"

def processImage():
    img = ImageGrab.grabclipboard()
    img.save('temp.png','PNG')
    pil_img = Image.open('temp.png')
    try:
        result = pytesseract.image_to_string(pil_img)
    except RuntimeError as error:
        pyperclip.copy(
            f"ERROR: An error occurred when trying to process the image: {error}")
        return

    if result:
        pyperclip.copy(result)
        print(f'INFO: Copied "{result}" to the clipboard')
    else:
        pyperclip.copy(f"INFO: Unable to read text from image, did not copy")


if __name__ == "__main__":
    processImage()
