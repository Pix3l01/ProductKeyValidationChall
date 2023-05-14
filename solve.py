import random
import hashlib
from Crypto.Util.number import bytes_to_long 

def check_first(n):
    if n in ["123", "456", "789"]:
        return False
    if len(set(n)) < len(n) or len(n) != 3:
        return False
    return True

def check_second(n):
    sum = 0
    if len(set(n)) < 6 or len(n) != 7:
        return False
    for c in n :
        sum += int(c)
    return (sum % 7 == 0)



def byte_xor(ba1, ba2):
    return bytes([_a ^ _b for _a, _b in zip(ba1, ba2)])

def int_to_24(n, len):
    table = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'M', 'P', 'Q', 'R', 'T', 'V', 'W', 'X', 'Y', '2', '3', '4', '6', '7', '8', '9']
    b24 = ['B']*len
    for i in range(len -1, -1, -1):
       b24[i]=table[n % 24] 
       n //= 24
    return ''.join(b24)

def b24_to_int(n):
    table = {'B':0, 'C':1, 'D':2, 'F':3, 'G':4, 'H':5, 'J':6,'K':7,'M':8, 'P':9, 'Q':10, 'R':11, 'T':12, 'V':13, 'W':14, 'X':15, 'Y':16, '2':17, '3':18, '4':19, '6':20, '7':21, '8':22, '9':23}
    num = 0
    for i, c in enumerate(n[::-1]):
        num += pow(24, i) * table[c]
    return num


def reduce(hash):
    a = [hash[i:i+4] for i in range(0, 40, 4)]
    reduced = ""
    for b in a:
        reduced += b[0] + b[-1]
    return reduced

def sign(n):
    hash_object = hashlib.sha1(hex(n)[2:].upper().encode())
    pbHash = hash_object.hexdigest().upper()
    reduced = reduce(pbHash)
    computed = byte_xor(bytes.fromhex(reduced), b'PWNTHEMALL')
    computed = bytes_to_long(computed)

    return int_to_24(computed, 18)


def main():
    key = ""
    # generate first part
    first = ""
    while(not check_first(first)):
        first = str(random.randint(102, 999))
    key += first + '-'

    # generate second part
    second = ""
    while(not check_second(second)):
        second = str(random.randint(100000, 9999999))
        second = '0'*(7-len(second)) + second
    key += second + '-'

    # generate third part
    key += random.choice(["ptm", "ctf", "plt"]) + '-'

    # I made a mistake in the checker: the conversion drops the leading zeros
    # so if the signature starts with a B (a zero) it will be considered incorrect
    # The loop generates a new random number and signature if this happens
    ok = False
    while(not ok):
        # generate fourth part
        fourth = random.randint(0, 7962623)

        # generate fifth part, which is the "signature" of the number generated for
        # the fourth part
        fifth = sign(fourth)
        
        if not fifth.startswith('B'):
            key += int_to_24(fourth, 5) + '-'
            key += fifth
            ok =  True

    print(key)

if __name__ == "__main__":
    main()

