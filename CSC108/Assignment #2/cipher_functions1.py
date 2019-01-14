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
    abcd
    >>> clean_message('cd12')
    cd
    """
    alphabet = ''
    for i in range(len(message)):
        if message[i].isalpha():
            alphabet = alphabet + message[i]
    return alphabet

def encrypt_letter(uppercase_letter, keysteam_value):
    """(str, int) -> str
    
    Return the letter encrypted by shipting keyseam_value to the right.
    
    >>> encrypt_letter('A', 2)
    C
    >>> encrypt_letter('C', 3)
    F
    """
    ord_diff = ord(uppercase_letter) - ord('A')
    new_char_ord = (ord_diff + keysteam_value) % 26
    return chr(new_char_ord + ord('A'))

def decrypt_letter(uppercase_letter, keysteam_value):
    """(str, int) -> str
    
    Return the letter encrypted by shipting keyseam_value to the left.
     
    >>> decrypt_letter('C', 2)
    A
    >>> decrypt_letter('F', 3)
    C
    """
    ord_diff = ord(uppercase_letter) - ord('A')
    new_char_ord = (ord_diff - keysteam_value) % 26
    return chr(new_char_ord + ord('A'))

def swap_cards(deck_of_cards, index):
    """(list of int,int) -> NoneType
    
    Swap the cards at the index with the card that follows it.
    
    >>> swap_cards([2,6,5,7,3,4,8],2)
    
    >>> swap_cards([5,9,6,4,7,8], 5)
    """
    
    card1 = deck_of_cards[index]
    card2 = deck_of_cards[(index + 1) % len(deck_of_cards)]
    deck_of_cards[(index + 1) % len(deck_of_cards)] = card1
    deck_of_cards[index] = card2

def get_big_joker_value(deck_of_cards):
    """(list of int) -> int
    
    Return the value of the big joker(value of the highest card) for the given 
    deck of cards.
    
    >>> get_big_joker_value([1,2,3,4,5,6,7])
    7
    >>> get_big_joker_value([5,8,9,6,10,7,11])
    11
    """
    big_joker_value = max(deck_of_cards)
    return big_joker_value

def get_small_joker_value(deck_of_cards):
    """(list of int) -> int
    
    Return the value of the small joker(value of the second highest card) for 
    the given deck of cards.
    
    >>> get_small_joker_value([1,2,3,4,5,6])
    5
    >>> get_small_joker_value([2,4,5,3,8,7,9,6])
    8
    """  
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = min(deck_of_cards)
    for card in deck_of_cards:
        if card < big_joker_value and card > small_joker_value:
            small_joker_value = card
    return small_joker_value


def move_small_joker(deck_of_cards):
    """(list of int) -> NoneType
    
    Swap the small joker with the card that follows it.
    
    >>> move_small_joker([1,2,3,4,6,5])
    
    >>> move_small_joker([5,8,9,7,6])
    
    """
    small_joker_value = get_small_joker_value(deck_of_cards)
    index = deck_of_cards.index(small_joker_value)
    deck_of_cards[index] = deck_of_cards[(index + 1) % len(deck_of_cards)]
    deck_of_cards[(index + 1) % len(deck_of_cards)] = small_joker_value
    
def move_big_joker(deck_of_cards):
    """(list of int) -> NoneType
    
    Move the big joker two cards down the deck of cards.
    
    >>> move_big_joker([1,2,3,4,5,6])
    
    >>> move_big_joker([5,8,9,7,6])
    
    """
    big_joker_value = get_big_joker_value(deck_of_cards)
    index1 = deck_of_cards.index(big_joker_value)
    deck_of_cards.pop(index1)
    index2 = (index1 + 1) % len(deck_of_cards)
    deck_of_cards.insert(index2 + 1, big_joker_value)
    
    
def triple_cut(deck_of_cards):
    """(list of int) -> NoneType
    
    >>> triple_cut([1,3,7,6,8,9,4,2,5])

    >>> triple_cut([1,2,4,6,5,0,3])

    """
    new_deck =[]
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
	    
    index1 = deck_of_cards.index(small_joker_value)
    index2 = deck_of_cards.index(big_joker_value)
    index_top_card = min(index1, index2)
    index_bottom_card = max(index1, index2)
    
    new_top = deck_of_cards[(index_bottom_card + 1):]
    middle = deck_of_cards[index_top_card : index_bottom_card + 1]
    new_bottom = deck_of_cards[:index_top_card]
    deck = new_top + middle + new_bottom
    deck_of_cards[:] = deck

def insert_top_to_bottom(deck_of_cards):
    """(list of int) -> NoneType
    
    Move the number of cards which has the same number as the value of bottom 
    cards to just on above the bottom cards in deck of cards.
    
    >>> insert_top_to_bottom([1,2,4,5,6,7,3])
    
    >>> insert_top_to_bottom([1,5,3,7,4,6,8,2,9])
    """
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
    last_card = deck_of_cards[-1]
    if last_card != big_joker_value:
        top_few_cards = deck_of_cards[: last_card]
        deck_of_cards.extend(top_few_cards)
        deck_of_cards[: last_card] = []
        deck_of_cards.remove(deck_of_cards[-(last_card + 1)])
        deck_of_cards.append(last_card)
    
def get_card_at_top_index(deck_of_cards):
    """(list of int) -> int
    
    Return the card_value that has the same value of index as the value of the 
    top card, which is called keystream_value.
    
    >>> get_card_at_top_index([4,5,3,9,7,8,2,6,1])
    7
    >>> get_card_at_top_index([6,4,3,5,1,2])
    2
    """
    big_joker_value = get_big_joker_value(deck_of_cards)
    small_joker_value = get_small_joker_value(deck_of_cards)
    first_card = deck_of_cards[0]
    if first_card == big_joker_value:
        return deck_of_cards[small_joker_value]
    else:
        return deck_of_cards[first_card]
     

def get_next_keystream_value(deck_of_cards):
    """(list of int) -> int
    
    Return the key_stream_value after repeat last five steps.
    
    >>>

    >>>
    """
    move_small_joker(deck_of_cards)
    move_big_joker(deck_of_cards)
    triple_cut(deck_of_cards)
    insert_top_to_bottom(deck_of_cards)
    keystream_value = get_card_at_top_index(deck_of_cards)
    
    if keystream_value == big_joker_value or \
       keystream_value == small_joker_value:
        keystream_value = get_next_keystream_value(deck_of_cards)

def read_messages(message_file):
    """(file open for reading) -> list of str
    
    Read and return the contents of the file as a list of messages, in the order 
    in which they appear in the file. Strip the newline from each line.
    """
    message_list = message_file.readlines()
    for line in message_list:
        line.strip('/n')
        
def is_valid_deck(deck_of_cards):
    """(list of int) -> bool
    
    Return True if and only if the candidata deck is a valid deck of cards, 
    meaning that it contains every integer from 1 up to the number of cards in
    the deck.
    
    >>> is_valid_deck([1,3,5,2,4,6])
    True
    >>> is_valid_deck([2,4,6,3,7])
    False
    """
    for card in range(1, len(deck_of_cards) + 1):
        if not card in deck_of_cards:
            return False
    return True

def read_deck(