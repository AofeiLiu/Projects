def process_data(twitter_data):
    """(file open for reading) -> Twitterverse dictionary

    Read the file and return the data in the Twitterverse dictionary format. 
    
    """
    twitter_line = twitter_data.readlines()
    Twitterverse_dictionary = {}
    username_list = get_username(twitter_line)
    list_of_profile = get_profile_dictionary(twitter_line)
    for i in range(len(username_list)):
            Twitterverse_dictionary[username_list[i]] = list_of_profile[i]
    return Twitterverse_dictionary
        
def get_next(index, twitter_line):
    """
    """
    index = twitter_line.index('END\n', index + 1,)
    return index

def get_end(twitter_line):
    """(list of str) -> list of int
    
    Returns the index value of all the 'END\n' within the twitter data
    """
    inverse_end = twitter_line[::-1]
    inverse_last_end = twitter_line[::-1].index('END\n')
    last_end = len(twitter_line) - 1 - inverse_end.index('END\n')
    last_two_end = len(twitter_line) - 1 - inverse_end.index('END\n', inverse_last_end + 1)    
    end_list = []
    i = twitter_line.index('END\n')
    while i < last_end:
        end_list.append(i)
        i = get_next(i, twitter_line)
    end_list.append(last_end)
    return end_list

def get_username(twitter_line):
    """(list of str) -> list of str
    """
    username_list = []
    username_list.append(twitter_line[0].strip('\n'))
    end = get_end(twitter_line)
    for i in range(len(end) - 1):
        username_list.append(twitter_line[end[i] + 1].strip('\n'))
    return username_list

def get_user_profile(twitter_line):
    """(list of str) -> list of list of str
    """
    ini_end = twitter_line.index('END\n')
    user_profile = [twitter_line[1 : ini_end]]
    end_list = get_end(twitter_line)
    for c in range(len(end_list) - 1):
        user_profile.append(twitter_line[end_list[c] + 2 : end_list[c + 1]])
        c = c + 1
    return user_profile

def get_bios(twitter_line):
    """(list of str) -> list of list of str
    """
    bios = []
    user_profile = get_user_profile(twitter_line)
    for item in user_profile:
        bios.append(item[3 : item.index('ENDBIO\n')])
    return bios

def get_bio(bios):
    """(list of str) -> str
    """
    bio = ''
    for info in bios:
        bio += info
    bio = bio.strip('\n')
    return bio
    
def get_bios(twitter_line):
    """(list of str) -> list of str
    """
    bios = []
    user_profile = get_user_profile(twitter_line)
    for item in user_profile:
        bios.append(item[3 : item.index('ENDBIO\n')])
    return bios

def get_following(twitter_line):
    """(list of str) -> list of list of str
    """
    user_following = []
    user_profile = get_user_profile(twitter_line)
    for item in user_profile:
        user_following.append(item[item.index('ENDBIO\n') + 1 : len(item)])
    return user_following

def get_profile_dictionary(twitter_line):
    """(list of list of str) -> list of dictionary
    """
    user_profile = get_user_profile(twitter_line)
    bio_list = get_bios(twitter_line)
    list_of_profile = []
    user_following = get_following(twitter_line)
    bio_str = ''
    for i in range(len(user_profile)):
        user_list = []
        profile_dictionary = {}
        profile_dictionary['name'] = user_profile[i][0].strip('\n')
        profile_dictionary['location'] = user_profile[i][1].strip('\n')
        profile_dictionary['web'] = user_profile[i][2].strip('\n')
        bio = get_bio(get_bios(twitter_line)[i])
        profile_dictionary['bio'] = bio
        for user in user_following[i]:
            user_list.append(user.strip('\n'))
            profile_dictionary['following'] = user_list
        list_of_profile.append(profile_dictionary)
    return list_of_profile

def process_query(query_data):
    """(file open for reading) -> query dicitonary
    
    Read the file and return the query in the query dictionary format.
    
    """
    query_line = query_data.readlines()
    query_dictionary = {}
    query_dictionary['search'] = get_search(query_line)
    query_dictionary['filter'] = get_filter(query_line)
    query_dictionary['present'] = get_present(query_line)
    return query_dictionary
    
def get_search(query_line):
    """(list of str) -> search dictioanry
    
    Return the dictionary of search
    
    """
    search_dictionary = {}
    search_dictionary['username'] = query_line[1].strip('\n')
    search_dictionary['operations'] = get_operations(query_line)
    return search_dictionary
    
def get_operations(query_line):
    """ (list of str) -> list of str
    
    Return the list of operations.
    
    """
    operations = []
    FILTER = query_line.index('FILTER\n')
    for line in query_line[2 : FILTER]:
        operations.append(line.strip('\n'))
    return operations

def get_filter(query_line):
    """ (list of str) -> filter dictionary
    
    Return the dictionary of filter.
    
    """
    filter_dictionary = {}
    FILTER = query_line.index('FILTER\n')
    PRESENT = query_line.index('PRESENT\n')
    for line in query_line[FILTER + 1 : PRESENT]:
        EMPTY = line.index(' ')
        key_filter = line[0 : EMPTY]
        value_filter = line[EMPTY + 1 : len(line)].strip('\n')
        filter_dictionary[key_filter] = value_filter
    return filter_dictionary

def get_present(query_line):
    """(list of str) -> present dictionary
    
    Return the dictionary of present
    
    """
    PRESENT = query_line.index('PRESENT\n')
    present_dictionary = {}
    for line in query_line[PRESENT + 1 : len(query_line)]:
        EMPTY = line.index(' ')
        key_present = line[0 : EMPTY]
        value_present = line[EMPTY + 1 : len(line)].strip('\n')
        present_dictionary[key_present] = value_present
    return present_dictionary

twitter_data = open('rdata.txt', 'r')
query_data = open('query3.txt', 'r')

def all_followers(Twitterverse_dictionary, username):
    """(Twitterverse dictionary, str) -> list of str
    
    """
    user_list = []
    for key in Twitterverse_dictionary:
        user_list.append(key)
    user_following = []
    for user in user_list:
        if username in Twitterverse_dictionary[user]['following']:
            user_following.append[user]
    return user_following