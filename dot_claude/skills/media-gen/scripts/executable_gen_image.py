#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["google-genai>=1.52.0", "Pillow>=11.0.0"]
# ///
"""
Generate or edit images using Google GenAI models.

Models:
- gemini-3.1-flash-image-preview (Nano Banana 2) - Speed-optimized
- gemini-2.5-flash-image (Nano Banana) - Fast, cost-effective
- gemini-3-pro-image-preview (Nano Banana Pro) - Professional quality, 4K
- imagen (Imagen 4) - Text-to-image, negative prompts

Usage:
    # Generate
    ./gen_image.py "A sunset over mountains" output.png
    ./gen_image.py "A cat portrait" cat.jpg --model gemini-3-pro-image-preview --aspect-ratio 9:16
    ./gen_image.py "Product photo" hero.png --model gemini-3-pro-image-preview --image-size 4K --aspect-ratio 16:9

    # Edit (provide input image)
    ./gen_image.py "Remove the background" output.png --input photo.jpg
    ./gen_image.py "Make it look like a watercolor painting" styled.png --input original.png
    ./gen_image.py "Add a hat to the cat" result.png --input cat.jpg --model gemini-3-pro-image-preview
"""

import argparse
import sys
from pathlib import Path

from google import genai
from google.genai import types
from PIL import Image


def generate_with_gemini(
    client: genai.Client,
    prompt: str,
    model: str,
    output_path: Path,
    aspect_ratio: str = "1:1",
    image_size: str | None = None,
    input_images: list[Path] | None = None,
) -> None:
    """Generate or edit image using Gemini models."""
    contents: list = []

    if input_images:
        for img_path in input_images:
            contents.append(Image.open(img_path))
        contents.append(prompt)
    else:
        contents = [prompt]

    image_config_kwargs: dict = {"aspect_ratio": aspect_ratio}
    if image_size:
        image_config_kwargs["image_size"] = image_size

    response = client.models.generate_content(
        model=model,
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(**image_config_kwargs),
        ),
    )

    for part in response.parts:
        if part.inline_data:
            image = part.as_image()
            image.save(str(output_path))
            print(f"Image saved to {output_path}")
            return

    print("Error: No image generated", file=sys.stderr)
    sys.exit(1)


def generate_with_imagen(
    client: genai.Client,
    prompt: str,
    model: str,
    output_path: Path,
    aspect_ratio: str = "1:1",
    negative_prompt: str | None = None,
) -> None:
    """Generate image using Imagen models."""
    suffix = output_path.suffix.lower()
    mime_type = "image/png" if suffix == ".png" else "image/jpeg"

    config = types.GenerateImagesConfig(
        number_of_images=1,
        aspect_ratio=aspect_ratio,
        output_mime_type=mime_type,
    )
    if negative_prompt:
        config.negative_prompt = negative_prompt

    response = client.models.generate_images(
        model=model,
        prompt=prompt,
        config=config,
    )

    if response.generated_images:
        response.generated_images[0].image.save(str(output_path))
        print(f"Image saved to {output_path}")
    else:
        print("Error: No image generated", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate or edit images with Google GenAI")
    parser.add_argument("prompt", help="Text prompt for image generation or editing")
    parser.add_argument("output", help="Output file path (e.g., output.png)")
    parser.add_argument(
        "--input",
        action="append",
        dest="inputs",
        help="Input image path(s) for editing. Repeat for multiple images (e.g., --input bg.png --input avatar.jpg)",
    )
    parser.add_argument(
        "--model",
        default="gemini-2.5-flash-image",
        choices=[
            "gemini-3.1-flash-image-preview",
            "gemini-2.5-flash-image",
            "gemini-3-pro-image-preview",
            "imagen",
            "imagen-3.0-generate-002",
        ],
        help="Model to use (default: gemini-2.5-flash-image)",
    )
    parser.add_argument(
        "--aspect-ratio",
        default="1:1",
        help="Aspect ratio (e.g., 1:1, 16:9, 9:16, 4:3)",
    )
    parser.add_argument(
        "--image-size",
        help="Output resolution for Gemini models (e.g., 4K). Pro model supports up to 4K.",
    )
    parser.add_argument(
        "--negative-prompt",
        help="What to avoid in generation (Imagen only)",
    )

    args = parser.parse_args()
    output_path = Path(args.output)
    input_images = [Path(p) for p in args.inputs] if args.inputs else None

    if input_images:
        for img_path in input_images:
            if not img_path.exists():
                print(f"Error: Input image not found: {img_path}", file=sys.stderr)
                sys.exit(1)

    if input_images and args.model.startswith("imagen"):
        print("Error: Image editing is not supported with Imagen models. Use a Gemini model.", file=sys.stderr)
        sys.exit(1)

    client = genai.Client()

    if args.model.startswith("gemini"):
        generate_with_gemini(
            client=client,
            prompt=args.prompt,
            model=args.model,
            output_path=output_path,
            aspect_ratio=args.aspect_ratio,
            image_size=args.image_size,
            input_images=input_images,
        )
    else:
        generate_with_imagen(
            client=client,
            prompt=args.prompt,
            model=args.model,
            output_path=output_path,
            aspect_ratio=args.aspect_ratio,
            negative_prompt=args.negative_prompt,
        )


if __name__ == "__main__":
    main()
