# Product key validation

## m0leCon CTF 2023 Teaser challenge

[m0leCon CTF 2023 Teaser](https://ctftime.org/event/1898) is an online jeopardy-style CTF organized by [pwnthem0le](https://pwnthem0le.polito.it/). The top 10 teams will be invited to the final event, which will take place in Fall 2023 at Politecnico di Torino.

### Description
Just a simple reverse chall to warm up<br>
The original flag has been substituted by `ptm{sample_flag}`

### Deploy
Both the `Dockerfile` and the `docker-compose.yaml` files are provided to launch the server through [Docker](https://www.docker.com/) on port `3232`<br>
It can be run locally provided that the system has the library `libgphobos` (on Ubuntu it can be installed with: `sudo apt install libgphobos-dev`)

## Solution
The executable is a product key validator inspired by Windows'.
At first, it checks the length (40) of the input and whether the key is composed of five parts divided by a `-`. Then, it checks the correctness of every part.<br>
In the fourth and fifth parts, the data are encoded in base24 using this custom alphabet: `BCDFGHJKMPQRTVWXY2346789`

* __First part:__
it must be an integer of three digits none of which can be repeated. Furthermore the numbers `123`, `456` and `789` are forbidden as well and the number can't start with a zero.

* __Second part:__ 
it must be an integer of seven digits and the sum of all its digits must be divisible by 7. Furthermore, the number must have at least 6 different digits.

* __Third part:__
it must be either one of these 3 letters strings: `"ptm", "ctf", "plt"`

* __Fourth part:__
it's a random base24 encoded value that must be 5 base24 digits (between `0` and `7962623` in base 10)

* __Fifth part:__
it's the base24 encoded signature of the fourth part and must be 18  base24 digits long. The signature is computed in three steps:
    
    1. The uppercase hexadecimal representation of the value gets hashed with `sha1`.
    2. The computed hash gets reduced from 20 bytes to 10: for every 2 bytes the right nibble of the first one and the left nibble of the second one get discarded (`fa3c -> fc`, `2b8d -> 2d`)
    3. The reduced hash gets xored with the string `PWNTHEMALL`

In the check of the signature I made a mistake: the conversion from base24 to hex drops all the leading zeros. So, if the signature starts with four or more 0 bits the key wouldn't be accepted, even though it should.

The python script `solve.py` generates (hopefully) working random keys.
