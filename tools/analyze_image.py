from PIL import Image
import subprocess
import json

img_path = "/home/zdiaks/projects/switch-sports-app/golfExample.jpg"
im = Image.open(img_path)
width, height = im.size
print(f"Image Size: {width} x {height}")

# In the image, the scorecard is horizontally centered, in the lower half of the screen.
# Let's crop just the scorecard area:
# x approx: 5% to 92% of width
# y approx: 54% to 68% of height
box = (int(width * 0.04), int(height * 0.53), int(width * 0.93), int(height * 0.69))
cropped = im.crop(box)
cropped.save("/home/zdiaks/projects/switch-sports-app/tools/scorecard_crop.png")
print(f"Saved scorecard crop: {box}")
