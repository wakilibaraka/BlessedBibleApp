import os
from rembg import remove
from PIL import Image

def process_image(input_path, output_path):
    print(f"Processing {input_path}...")
    with open(input_path, 'rb') as i:
        input_data = i.read()
    
    # Use alpha matting to better preserve edges and beams
    output_data = remove(input_data, alpha_matting=True)
    
    with open(output_path, 'wb') as o:
        o.write(output_data)
    print(f"Saved to {output_path}")

def main():
    img1 = "/Users/baraka/.gemini/antigravity/brain/eedebcfd-216e-4425-a5f3-9167a9bc8533/.user_uploaded/media__1784699268261.png"
    img2 = "/Users/baraka/.gemini/antigravity/brain/eedebcfd-216e-4425-a5f3-9167a9bc8533/.user_uploaded/media__1784699523147.png"
    
    out_dir = "/Users/baraka/the_blessed_bible/assets/images"
    os.makedirs(out_dir, exist_ok=True)
    
    process_image(img1, os.path.join(out_dir, "lighthouse_1.png"))
    process_image(img2, os.path.join(out_dir, "lighthouse_2.png"))

if __name__ == "__main__":
    main()
