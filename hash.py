import hashlib
import sys

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print("Use: python3 %s <filepath>" %(sys.argv[0]))
    else:
        func = hashlib.sha256()

        with open(sys.argv[1], 'rb') as file:
            buffer = file.read()
            func.update(buffer)

        print("0x%s" %func.hexdigest().upper())
