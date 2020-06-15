"""
Devops challenge

(c) 2020 - GHGSat inc.
"""
from pathlib import Path
import click

from PIL import Image
from PIL import UnidentifiedImageError

import logging

@click.command()
@click.argument("input", type=click.Path(exists=True, dir_okay=True, file_okay=False))
@click.argument("output", type=click.Path(exists=True, dir_okay=True, file_okay=False))
def main(input, output):
    click.echo("Starting up....")
    input = Path(input)
    output = Path(output)
    click.echo(f"Going through {input} and writing to {output}")
    for image in input.iterdir():
        output_image = output / image.name
        click.echo(f"in: {image}, out: {output_image}")
        process(image, output_image)
    click.echo("Done")


def process(input, output):
    """
    Perform advanced image process on image at input and write result to
    ouput
    """
    try:
        image = Image.open(input)
        new_image = image.rotate(90, expand=True)
        new_image.save(output)
    except UnidentifiedImageError:
        logging.warning('File is not an image')
    except ValueError:
        logging.warning('Can not read file')
    except FileNotFoundError:
        logging.waring('File not found')

if __name__ == "__main__":
    main()
