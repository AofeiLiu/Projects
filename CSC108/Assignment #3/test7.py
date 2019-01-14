expected = open('expected.txt', 'r')
result = open('result.txt', 'r')
a = expected.readlines()
b = result.readlines()
for char1 in a:
    for char2 in b:
        if char1 == char2:
            print(char1 == char2)
            

    