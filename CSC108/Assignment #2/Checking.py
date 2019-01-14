import cipher_functions

DECRYPT = 'd'
ENCRYPT = 'e'

deck_of_cards = cipher_functions.read_deck(open('deck1.txt', 'r'))
list_of_messages = cipher_functions.read_messages(open('message_file1.txt', 'r'))
print(list_of_messages)
# encrypt = cipher_functions.process_messages(deck_of_cards, list_of_messages, 'e')

print(encrypt)

deck_of_cards = cipher_functions.read_deck(open('deck1.txt', 'r'))
print(cipher_functions.process_messages(deck_of_cards, encrypt, 'd'))