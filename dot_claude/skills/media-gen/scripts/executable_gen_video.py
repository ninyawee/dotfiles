#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["google-genai>=1.52.0"]
# ///
"""
Generate videos using Google GenAI Veo models.

Models:
- veo-3.1-generate-preview - High quality with audio
- veo-3.1-fast-generate-preview - Faster generation
- veo-3.0-generate-preview - Previous generation

Usage:
    ./gen_video.py "A cat walking" output.mp4
    ./gen_video.py "A sunset timelapse" output.mp4 --model veo-3.1-fast-generate-preview
    ./gen_video.py "A dog running" output.mp4 --image input.jpg
    ./gen_video.py "Epic scene" output.mp4 --negative-prompt "blurry, low quality"
"""

import argparse
import sys
import time
from pathlib import Path

from google import genai
from google.genai import types


def generate_video(
    client: genai.Client,
    prompt: str,
    output_path: Path,
    model: str = "veo-3.1-generate-preview",
    image_path: Path | None = None,
    negative_prompt: str | None = None,
    poll_interval: int = 10,
) -> None:
    """Generate video from text prompt, optionally with image input."""
    config = None
    if negative_prompt:
        config = types.GenerateVideosConfig(negative_prompt=negative_prompt)

    kwargs: dict = {
        "model": model,
        "prompt": prompt,
    }
    if config:
        kwargs["config"] = config

    # If image provided, use image-to-video
    if image_path:
        # First upload the image
        print(f"Uploading image: {image_path}")
        uploaded_file = client.files.upload(file=str(image_path))
        kwargs["image"] = uploaded_file

    print(f"Starting video generation with {model}...")
    operation = client.models.generate_videos(**kwargs)

    # Poll until complete
    while not operation.done:
        print("Waiting for video generation...")
        time.sleep(poll_interval)
        operation = client.operations.get(operation)

    if not operation.response or not operation.response.generated_videos:
        print("Error: No video generated", file=sys.stderr)
        sys.exit(1)

    # Download and save
    generated_video = operation.response.generated_videos[0]
    client.files.download(file=generated_video.video)
    generated_video.video.save(str(output_path))
    print(f"Video saved to {output_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate videos with Veo")
    parser.add_argument("prompt", help="Text prompt for video generation")
    parser.add_argument("output", help="Output file path (e.g., output.mp4)")
    parser.add_argument(
        "--model",
        default="veo-3.1-generate-preview",
        choices=[
            "veo-3.1-generate-preview",
            "veo-3.1-fast-generate-preview",
            "veo-3.0-generate-preview",
        ],
        help="Veo model to use (default: veo-3.1-generate-preview)",
    )
    parser.add_argument(
        "--image",
        help="Input image for image-to-video generation",
    )
    parser.add_argument(
        "--negative-prompt",
        help="What to avoid in generation",
    )
    parser.add_argument(
        "--poll-interval",
        type=int,
        default=10,
        help="Seconds between status checks (default: 10)",
    )

    args = parser.parse_args()
    output_path = Path(args.output)
    image_path = Path(args.image) if args.image else None

    if image_path and not image_path.exists():
        print(f"Error: Image not found: {image_path}", file=sys.stderr)
        sys.exit(1)

    client = genai.Client()

    generate_video(
        client=client,
        prompt=args.prompt,
        output_path=output_path,
        model=args.model,
        image_path=image_path,
        negative_prompt=args.negative_prompt,
        poll_interval=args.poll_interval,
    )


if __name__ == "__main__":
    main()
