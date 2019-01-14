# Functions for running an encryption or decryption algorithm

ENCRYPT = 'e'
DECRYPT = 'd'

# Write your functions after this comment.  Do not change the statements above
# this comment.  Do not use import, open, input or print statements in the 
# code that you submit.  Do not use break or continue statements.

def clean_message(message):
    """ (str) -> str
    
    Return a copy of message that includes only its alphabetical characters, 
    where each of those charactes has been converted to uppercase.
    
    >>> clean_message('ab cd12')
    'ABCD'
    >>> clean_message('cd12')
    'CD'
    """
    alphabet = ''
    for i in range(len(message)):
        if message[i].isalpha():
            alphabet = alphabet + message[i].upper()
    return alphabet
    # Will obtain a str that will only contain alphabets that are uppercase.
    
def encrypt_letter(uppercase_letter, keystream_value):
    """(str, int) -> str
    
    Return the letter encrypted by shipting keyseam_value to the right.
    
    >>> encrypt_letter('A', 2)
    'C'
    >>> encrypt_letter('C', 3)
    'F' 
    """
    ord_diff = ord(uppercase_letter) - ord('A')
    new_char_ord = (ord_diff + keystream_value) % 26
    # % 26 allows for the new letter to remain in the 26 letter english alphabet
    return chr(new_char_ord + ord('A'))

def decrypt_letter(uppercase_letter, keystream_value):
    """(str, int) -> str
    
    Return the letter encrypted by shipting keyseam_value to the left.
     
    >>> decrypt_letter('C', 2)
    'A'
    >>> decrypt_letter('F', 3)
    'C'
    """   
    ord_diff = ord(uppercase_letter) - ord('A')
    new_char_ord = (ord_diff - keystream_value) % 26
    # Reverse keystream_value of encryption
    return chr(new_char_ord + ord('A'))

def swap_cards(deck_of_cards, index):
    """(list of int,int) -> NoneType
    
    Swap the cards at the index with the card that follows it.
    
    >>> swap_cards([1, 2, 5, 4, 6, 3, 7], 2)
    
    >>> swap_cards([1, 3, 4, 2, 11, 6, 5, 8, 9, 7, 10], 5)

    """

    if index != len(deck_of_cards) - 1:
        card1 = deck_of_cards[index + 1]
        deck_of_cards[index + 1] = deck_of_cards[index]
        deck_of_cards[index] = card1
    else:
        card1 = deck_of_cards[index]
        deck_of_cards[index] = deck_of_cards[0]
        deck_of_cards[0] = card1
    # two cases where if the index given is the last card or not. If last card
    # will switch with the first card. If not last card will switch card at
    # the given index with the card that follows.
    '''    
    card1 = deck_of_cards[index]
    card2 = deck_of_cards[(index + 1) % len(deck_of_cards)]
    
    deck_of_cards[(index + 1) % len(deck_of_cards)] = card1
    deck_of_cards[index] = card2
    '''
    # Function takes the card at the index and changes it to the value of the
    # card of the index that is below in the deck. Then the index that is below
    # takes on the first card's value. 
    
def get_small_joker_value(deck_of_cards):
    """(list of int) -> int
    
    Return the value of the small joker(value of the second highest card) for 
    the given deck of cards.
    
    >>> get_small_joker_value([1, 2, 4, 5, 6, 3, 7])
    6
    >>> get_small_joker_value([1, 3, 4, 2, 11, 5, 6, 8, 9, 7, 10])
    10
    """  
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = min(deck_of_cards)
    
    for card in deck_of_cards:
        if card < big_joker_value and card > small_joker_value:
            small_joker_value = card
    # Goes through each card in the deck_of_cards and checks that it is greater
    # than the other cards but is smaller than the big_joker    
    return small_joker_value

def get_big_joker_value(deck_of_cards):
    """(list of int) -> int 
    
    Return the value of the big joker(value of the highest card) for the given 
    deck of cards.
    
    >>> get_big_joker_value([1, 2, 4, 5, 6, 3, 7])
    7
    >>> get_big_joker_value([1, 3, 4, 2, 11, 5, 6, 8, 9, 7, 10])
    11
    """
    big_joker_value = max(deck_of_cards)
    return big_joker_value
    # big_joker is the largest card, thus max() function

def move_small_joker(deck_of_cards):
    """(list of int) -> NoneType
    
    Swap the small joker with the card that follows it.
    
    >>> move_small_joker([1, 2, 4, 5, 6, 3, 7])
    
    >>> move_small_joker([1, 3, 4, 2, 11, 5, 6, 8, 9, 7, 10])
    
    """
    small_joker_value = get_small_joker_value(deck_of_cards)
    index = deck_of_cards.index(small_joker_value)
    swap_cards(deck_of_cards, index)
    
    # Changing the list such that the small_joker card switches values with the 
    # card that follows it in the list
    
def move_big_joker(deck_of_cards):
    """(list of int) -> NoneType
    
    Move the big joker two cards down the deck of cards.
    
    >>> move_big_joker([1, 2, 4, 5, 3, 6, 7])
    
    >>> move_big_joker([10, 3, 4, 2, 11, 5, 6, 8, 9, 7, 1])
    
    """
    
    i = 0
    for i in range(2):
        big_joker_value = get_big_joker_value(deck_of_cards)
        big_joker_index = deck_of_cards.index(big_joker_value)
        swap_cards(deck_of_cards, big_joker_index)
        i = i + 1
    # moves the big_joker_value down the card two indices. If at the end will
    # wrap around to the beginning of the deck.
    
def triple_cut(deck_of_cards):
    """(list of int) -> NoneType
    
    >>> triple_cut([1, 2, 7, 4, 5, 3, 6])
    
    >>> triple_cut([10, 3, 4, 2, 5, 6, 11, 8, 9, 7, 1])
    """
    new_deck =[]
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
	    
    index1 = deck_of_cards.index(small_joker_value)
    index2 = deck_of_cards.index(big_joker_value)
    index_top_card = min(index1, index2)
    index_bottom_card = max(index1, index2)
    # This function will give us the joker that is on the top and the joker 
    # that is in the bottom of the deck regardless of their value
    
    new_top = deck_of_cards[(index_bottom_card + 1):]
    # Creates a deck that is to be moved the top, from the lower joker and
    # below    
    middle = deck_of_cards[index_top_card : index_bottom_card + 1]
    # Middle portion of the deck that is not moved that is in between the jokers
    new_bottom = deck_of_cards[:index_top_card]
    # The deck portion that is to be moved to the bottom, from higher joker and
    # above.
    deck = new_top + middle + new_bottom
    deck_of_cards[:] = deck
    # This will then give a new deck that shifts the cards above the higher 
    # joker to the end and the cards below the lower joker to the top.

def insert_top_to_bottom(deck_of_cards):
    """(list of int) -> NoneType
    
    Move the number of cards which has the same number as the value of bottom 
    cards to just on above the bottom cards in deck of cards.
    
    >>> insert_top_to_bottom([7, 4, 5, 3, 6, 1, 2])
    
    >>> insert_top_to_bottom([8, 9, 7, 1, 10, 3, 4, 2, 5, 6, 11])
    """
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
    last_card = deck_of_cards[len(deck_of_cards) - 1]
    if not last_card == big_joker_value:
        top_few_cards = deck_of_cards[: last_card]
        deck_of_cards.extend(top_few_cards)
	# top_few_cards represents portion of deck to last_card index. This is 
	# added to the bottom of the deck.
        deck_of_cards[: last_card] = []
	# Removes the duplicates
        deck_of_cards.remove(deck_of_cards[-(last_card + 1)])
        deck_of_cards.append(last_card)
        # This then added the last card to the bottom of the deck.
    
def get_card_at_top_index(deck_of_cards):
    """(list of int) -> int
    
    Return the card_value that has the same value of index as the value of the 
    top card, which is called keystream_value.
    
    >>> get_card_at_top_index([5, 3, 6, 1, 7, 4, 2])
    5
    >>> get_card_at_top_index([8, 9, 7, 1, 10, 3, 4, 2, 5, 6, 11])
    8
    """
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
    first_card = deck_of_cards[0]
    
    if first_card == big_joker_value:
        return deck_of_cards[small_joker_value]
    else:
        return deck_of_cards[first_card]
    # Consideres two cases where if the first_card is big_joker_value then 
    # the card that has the index small_joker_value is returned. Else it will 
    # return the card that has the index of the first_card.

def get_next_keystream_value(deck_of_cards):
    """(list of int) -> int
    
    Return the key_stream_value after repeating last five steps.
    
    >>> get_next_keystream_value[1, 2, 4, 5, 6, 3, 7]
    4
    
    >>> get_next_keystream_value[8, 9, 7, 1, 10, 3, 4, 2, 5, 6, 11]
    5
    
    """
    get_big_joker_value(deck_of_cards)
    get_small_joker_value(deck_of_cards)
    move_small_joker(deck_of_cards)
    move_big_joker(deck_of_cards)
    triple_cut(deck_of_cards)
    insert_top_to_bottom(deck_of_cards)
    keystream_value = get_card_at_top_index(deck_of_cards)
    
    if keystream_value == get_big_joker_value(deck_of_cards) or \
       keystream_value == get_small_joker_value(deck_of_cards):
        keystream_value = get_next_keystream_value(deck_of_cards)
    return keystream_value
	
    # Condition where if keystream_value is equal to big_joker_value or
    # small_joker_value then this will be repeated. After occuring it is then 
    # checked again to see if keystream_value is equal to big_joker_value or
    # small_joker_value. If so, then again repeated until not so.

def process_messages(deck_of_cards, list_of_messages, method):
    """(list of int, list of str, str) -> list of str
    
    Precondition: list_of_messages is a cleaned message consisting of only \
    capital letters. deck_of_cards is a valid deck for the given language.
    
    Return a list of encrypted or decrypted messages, in the same order as they 
    appear in the given list of messages. Note that the first parameter my also 
    be mutated during a function call
    
    >>>process_messages([1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 3, 6, 9, 12, 15, \
    18, 21, 24, 27, 2, 5, 8, 11, 14, 17, 20, 23, 26 ], \
    ['LEL', 'IGOTDIS', 'EYYYY', 'C', 'ME'], 'e')
    ['WNI', 'PQNEOPA', 'NJJYW', 'H', 'VY']
    
    >>>process_messages([1, 2, 4, 5, 6, 3, 7], ['JIX', 'KH'], 'd')
    ['LEL', 'IGOTDIS', 'EYYYY', 'C', 'ME']
    """
    output_message = []
    for string in list_of_messages:    
        output_message.append(clean_message(string))
	
    if method == ENCRYPT:
        for i in range(len(output_message)):
            letter = ""
            for string in list_of_messages[i]:
                keystream_value = get_next_keystream_value(deck_of_cards)
                letter = letter + encrypt_letter(string, keystream_value)
            output_message[i] = letter
	    
    elif method == DECRYPT:
        for i in range(len(output_message)):
            letter = ""
            for string in list_of_messages[i]:
                keystream_value = get_next_keystream_value(deck_of_cards)
                letter = letter + decrypt_letter(string, keystream_value)
            output_message[i] = letter
    return output_message
    # Two cases where if method is ENCRYPT or DECRYPT. if DECRYPT uses
    # decrypt_letter method. If ENCRYPT uses encrypt_letter method.
    
def read_messages(message_file):
    """(file open for reading) -> list of str
    
    Read and return the contents of the file as a list of messages, in the order 
    in which they appear in the file. Strip the newline from each line.
    
    """
    line = message_file.readline()
    messages = []
    
    while line != '':
        line = clean_message(line)
        line = line.strip('\n')
        messages.append(line)
        line = message_file.readline()
    return messages
	
    # Function will go through each line removing occurences of '/n'
    
def is_valid_deck(deck_of_cards):
    """(list of int) -> bool
    
    Return True if and only if the candidata deck is a valid deck of cards, 
    meaning that it contains every integer from 1 up to the number of cards in
    the deck.
    
    >>> is_valid_deck([1, 3, 5, 2, 4, 6])
    True
    
    >>> is_valid_deck([2, 4, 6, 3, 7])
    False
    
    >>> is_valid_deck([1, 3, 2, 1])
    False
    """
    new_deck = deck_of_cards[:]
    new_deck.sort()
    
    for i in range(len(new_deck)):
        if new_deck[i] != (i + 1):
            return False
    return True
    # Checks to see if each value from 1 to number of cards in the given deck 
    # appears once.

def read_deck(message_file):
    """(file open for reading) -> list of int
    
    Read and return the numbers that are in the file, in the order in which
    they appear in the file. 
    """
    list_int = []
    message_string = message_file.readline()
    
    while message_string != '':
        message_string = message_string.rstrip('\n')
        message_list = message_string.split(' ')
        for element in message_list:
            if element.isnumeric():
                list_int.append(int(element))
        message_string = message_file.readline()
    return list_int
    # Function will split the str. from file into list of str and convert each
    # item in the list to an int.