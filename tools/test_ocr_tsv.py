import subprocess
from PIL import Image

# Let's inspect tesseract TSV output with bounding boxes on the cropped scorecard
crop_path = "/home/zdiaks/projects/switch-sports-app/tools/scorecard_crop.png"
res = subprocess.run(["tesseract", crop_path, "stdout", "--psm", "6", "tsv"], capture_output=True, text=True)

lines = res.stdout.strip().split("\n")
print(f"Total TSV rows: {len(lines)}")
header = lines[0].split("\t")
print("TSV Header:", header)

for line in lines[1:]:
    parts = line.split("\t")
    if len(parts) >= 12:
        text = parts[11].strip()
        conf = parts[10]
        if text:
            left, top, width, height = parts[6], parts[7], parts[8], parts[9]
            print(f"[{left},{top},{width},{height}] conf={conf}: {text}")
