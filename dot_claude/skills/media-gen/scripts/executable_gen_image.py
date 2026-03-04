#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["google-genai>=1.52.0"]
# ///
"""
Generate images using Google GenAI models.

Models:
- gemini-2.5-flash-image (Nano Banana) - Fast, cost-effective
- gemini-3.0-pro-image (Nano Banana Pro) - High quality, 4K support
- imagen-3.0-generate-002 - Imagen model

Usage:
    ./gen_image.py "A sunset over mountains" output.png
    ./gen_image.py "A cat" output.jpg --model gemini-2.5-flash-image
    ./gen_image.py "A portrait" output.png --model imagen-3.0-generate-002 --aspect-ratio 9:16
"""

import argparse
import sys
from pathlib import Path

from google import genai
from google.genai import types


def generate_with_gemini(
    client: genai.Client,
    prompt: str,
    model: str,
    output_path: Path,
    aspect_ratio: str = "1:1",
) -> None:
    """Generate image using Gemini models (Nano Banana / Nano Banana Pro)."""
    response = client.models.generate_content(
        model=model,
        contents=prompt,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(
                aspect_ratio=aspect_ratio,
            ),
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
    parser = argparse.ArgumentParser(description="Generate images with Google GenAI")
    parser.add_argument("prompt", help="Text prompt for image generation")
    parser.add_argument("output", help="Output file path (e.g., output.png)")
    parser.add_argument(
        "--model",
        default="gemini-2.5-flash-image",
        choices=[
            "gemini-2.5-flash-image",
            "gemini-3.0-pro-image",
            "imagen-3.0-generate-002",
            "imagen-3.0-fast-generate-001",
        ],
        help="Model to use (default: gemini-2.5-flash-image)",
    )
    parser.add_argument(
        "--aspect-ratio",
        default="1:1",
        help="Aspect ratio (e.g., 1:1, 16:9, 9:16, 4:3)",
    )
    parser.add_argument(
        "--negative-prompt",
        help="What to avoid in generation (Imagen only)",
    )

    args = parser.parse_args()
    output_path = Path(args.output)

    client = genai.Client()

    if args.model.startswith("gemini"):
        generate_with_gemini(
            client=client,
            prompt=args.prompt,
            model=args.model,
            output_path=output_path,
            aspect_ratio=args.aspect_ratio,
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
