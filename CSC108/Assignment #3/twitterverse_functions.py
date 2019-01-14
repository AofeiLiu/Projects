"""
Type descriptions of Twitterverse and Query dictionaries
(for use in docstrings)

Twitterverse dictionary:  dict of {str: dict of {str: object}}
    - each key is a username (a str)
    - each value is a dict of {str: object} with items as follows:
        - key "name", value represents a user's name (a str)
        - key "location", value represents a user's location (a str)
        - key "web", value represents a user's website (a str)
        - key "bio", value represents a user's bio (a str)
        - key "following", value represents all the usernames of users this 
          user is following (a list of str)
       
Query dictionary: dict of {str: dict of {str: object}}
   - key "search", value represents a search specification dictionary
   - key "filter", value represents a filter specification dictionary
   - key "present", value represents a presentation specification dictionary

Search specification dictionary: dict of {str: object}
   - key "username", value represents the username to begin search at (a str)
   - key "operations", value represents the operations to perform (a list of str)

Filter specification dictionary: dict of {str: str}
   - key "following" might exist, value represents a username (a str)
   - key "follower" might exist, value represents a username (a str)
   - key "name-includes" might exist, value represents a str to match (a case-insensitive match)
   - key "location-includes" might exist, value represents a str to match (a case-insensitive match)

Presentation specification dictionary: dict of {str: str}
   - key "sort-by", value represents how to sort results (a str)
   - key "format", value represents how to format results (a str)
       
"""
# Write your Twitterverse functions here

def process_data(twitter_data):
    """(file open for reading) -> Twitterverse dictionary
    
    Read the file and return the data in the Twitterverse dictionary format. 
    
    """
    
    twitterverse_dict = {}
    twitter_line = get_clean(twitter_data)
    i = 0
    while i < len(twitter_line):
        profile = get_profile(twitter_line, i)
        # places the 'name', 'location' and 'web' aspects into the profile dict
        j = 4
        bio =''
        while twitter_line[i + j] != 'ENDBIO':
            bio += (twitter_line[i + j]) + '\n'
            j += 1
        # compiles the bio portion of a profile into a single string.
        profile['bio'] = bio[:-1]
        j += 1
        user_following = []
        while twitter_line[i + j] != 'END':
            user_following.append(twitter_line[i + j])
            j += 1
        # compiles usernames within the following section into user_following
        # list.
        
        profile['following'] = user_following
        twitterverse_dict[twitter_line[i]] = profile
        i += j + 1

    return twitterverse_dict


def process_query(query_data):
    """(file open for reading) -> query dicitonary
    
    Read the file and return the queries in the query dictionary format.
    
    """
    
    query_line = []
    
    for line in query_data:
        query_line.append(line.strip())
    query_dictionary = {}
    filter_dict = {}
    search_dict = {}
    present_dict = {}
    
    search_dict['username'] = query_line[1]
    search_dict['operations'] = query_line[2 : query_line.index('FILTER')]
    # compiles the Search Specification portion of the query data into a search 
    # dictionary
    
    for line in query_line[query_line.index('FILTER') + 1 : \
                           query_line.index('PRESENT')]:
        EMPTY = line.index(' ')
        filter_dict[line[0 : EMPTY]] = line[EMPTY + 1: len(line)]
    # compiles the Filter Specification portion of the query data into a filter 
    # dictionary
        
    for line in query_line[query_line.index('PRESENT') + 1 : len(query_line)]:
        EMPTY = line.index(' ')
        present_dict[line[0 : EMPTY]] = line[EMPTY + 1 : len(line)]
    # compiles the Presentation Specification portion of the query data into a 
    # presentation dictionary
    
    query_dictionary['search'] = search_dict
    query_dictionary['filter'] = filter_dict
    query_dictionary['present'] = present_dict
    return query_dictionary

def all_followers(twitterverse_dict, username):
    """(Twitterverse dictionary, str) -> list of str
    
    Return the users that have the specified username as a value in the 
    'following' dictionary of their 'user' dictionary. Return empty list if none
    found.
    
    >>> twitterverse_dict = {'b': {'name': 'BRIAN', 'location': '', 'web': '', \
    'following': ['c'], 'bio': 'Whose eyes are those eyes?'}, \
    'c': {'name': 'charles.kappa', 'location': 'L', 'web': '...', \
    'following': ['a'], 'bio': ''}, 'a': {'name': 'John Smith', \
    'location': 'CA, le32c', 'web': 'http://haruhi.com', \
    'following': ['b', 'c'], 'bio': 'Hello! This is John Smith\\nSOS\\n'}}
    
    >>> followers = all_followers(twitterverse_dict, 'c')
    >>> followers.sort()
    >>> followers == ['a', 'b']
    True
    
    >>> followers = all_followers(twitterverse_dict, 'a')
    >>> followers.sort()
    >>> followers == ['c']
    True
    
    >>> followers = all_followers(twitterverse_dict, 'd')
    >>> followers == []
    True
    """
    
    followers = []
    for users in twitterverse_dict:
        if username in twitterverse_dict[users]['following']:
            followers.append(users)
    return followers

def get_search_results(twitterverse_dict, search_specific_dict):
    """(Twitterverse dictionary, search specification dictionary) -> list of str
    
    Return a list of usernames for which the specified operations matches their
    follower/following status. Duplicates are removed.
    
    >>> twitterverse_dict = {'b': {'name': 'BRIAN', 'location': '', 'web': '', \
    'following': ['c'], 'bio': 'Whose eyes are those eyes?'}, \
    'c': {'name': 'charles.kappa', 'location': 'L', 'web': '...', \
    'following': ['a'], 'bio': ''}, 'a': {'name': 'John Smith', \
    'location': 'CA, le32c', 'web': 'http://haruhi.com', \
    'following': ['b', 'c'], 'bio': 'Hello! This is John Smith\\nSOS\\n'}}
    
    >>> search_specific_dict = {'username': 'a', 'operations': ['following']}
    >>> results = get_search_results(twitterverse_dict, search_specific_dict)
    >>> results.sort()
    >>> results
    ['b', 'c']
    
    >>> search_specific_dict = {'username': 'a', 'operations': ['follower']}
    >>> results = get_search_results(twitterverse_dict, search_specific_dict)
    >>> results.sort()
    >>> results
    ['c']
    
    >>> search_specific_dict = {'username': 'a', 'operations': ['following', \
    'following']}
    >>> results = get_search_results(twitterverse_dict, search_specific_dict)
    >>> results.sort()
    >>> results
    ['a', 'c']
    
    >>> search_specific_dict = {'username': 'a', 'operations': ['following', \
    'follower']}
    >>> results = get_search_results(twitterverse_dict, search_specific_dict)
    >>> results.sort()
    >>> results
    ['a', 'b']
    
    >>> search_specific_dict = {'username': 'd', 'operations': ['following']}
    >>> results = get_search_results(twitterverse_dict, search_specific_dict)
    >>> results.sort()
    >>> results
    []
    """
    
    find_user = search_specific_dict['username']
    match_user = [find_user]
    operation_list = search_specific_dict['operations']
    
    for operation in operation_list:
        match_list = []
        for user in match_user:
            if user in twitterverse_dict:
                if operation == 'following':
                    match_list.extend(twitterverse_dict[user]['following'])
                else:
                    match_list.extend(all_followers(twitterverse_dict, user))
    # compiles for each username on created list using the specified operation 
    # until all operations done for each name acquired. 
        match_user = list(set(match_list))
    return match_user

def get_filter_results(twitterverse_dict, match_users, \
                       filter_specific_dict):
    """(Twitterverse dictionary, list of str, filter specification dictionary) \ 
    -> list of str
    
    Return a list of usernames that match the given filters. If no filters given
    will return original list.
    
    >>> twitterverse_dict = {'b': {'name': 'BRIAN', 'location': '', 'web': '', \
    'following': ['c'], 'bio': 'Whose eyes are those eyes?'}, \
    'c': {'name': 'charles.kappa', 'location': 'L', 'web': '...', \
    'following': ['a'], 'bio': ''}, 'a': {'name': 'John Smith', \
    'location': 'CA, Le32c', 'web': 'http://haruhi.com', \
    'following': ['b', 'c'], 'bio': 'Hello! This is John Smith\\nSOS\\n'}, \
    'd': {'name': 'WATASHI KININARIMASU', 'location': 'zoCp', \
    'web': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', \
    'following': ['a', 'b', 'c'], 'bio': 'Hotaru-san, nandesuka?'}}
    >>> match_users = ['a', 'c', 'd']
    
    >>> filter_specific_dict = {}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['a', 'c', 'd']
    
    >>> filter_specific_dict = {'following': 'a', 'follower': 'b', \
    'location-includes': 'l', 'name-includes': 'a'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['c']
    
    >>> filter_specific_dict = {'following': 'a', 'follower': 'b', \
    'location-includes': 'L', 'name-includes': 'A'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['c']
    
    >>> filter_specific_dict = {'following': 'a', 'location-includes': 'c', \
    'name-includes': 'w'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['d']
    
    >>> filter_specific_dict = {'follower': 'd', 'location-includes': 'l', \
    'name-includes': 'h'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['a', 'c']
    
    >>> filter_specific_dict = {'follower': 'c', 'following': 'c', \
    'name-includes': 'h'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    ['a']
    
    >>> filter_specific_dict = {'follower': 'b', 'following': 'c', \
    'location-includes': 'c'}
    >>> get_filter_results(twitterverse_dict, match_users, filter_specific_dict)
    []
    
    """
    
    if len(filter_specific_dict) > 0:
        entries = sorted(list(filter_specific_dict.keys()))
        for i in range(0, len(entries)):
            filter_users = match_users
            filter_users = filter_result(twitterverse_dict, match_users, \
                       filter_specific_dict, entries[i])
            match_users = filter_users
        # loop to filter the list of usernames, and using the same list in
        # further filters or returning if no other filter operations.
        return match_users
    else:
        return match_users

def get_present_string(twitterverse_dict, filter_user, present_specific_dict):
    """(Twitterverse dictionary, list of str, \
    Presentation Specification dictionary) -> str
    
    Return a string of the filter_users in a format depending on the 
    presentation specifications. Will first sort depending on the keyword. Will
    then choose a presentation style. If long, will return all information. 
    If short, will return only usernames.
    
    >>> twitterverse_dict = {'b': {'name': 'BRIAN', 'location': '', 'web': '', \
    'following': ['c'], 'bio': 'Whose eyes are those eyes?'}, \
    'c': {'name': 'zappa kappa', 'location': 'L', 'web': '...', \
    'following': ['a'], 'bio': ''}, 'a': {'name': 'John Smith', \
    'location': 'CA, le32c', 'web': 'http://haruhi.com', \
    'following': ['b', 'c'], 'bio': 'Hello! This is John Smith\\nSOS\\n'}, \
    'd': {'name': 'WATASHI KININARIMASU', 'location': 'zop', \
    'web': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', \
    'following': ['a', 'b', 'c'], 'bio': 'Hotaru-san, nandesuka?'}}
    >>> filter_user = ['a', 'd', 'c']
    
    >>> present_specific_dict = {'sort-by': 'username', 'format': 'long'}
    >>> get_present_string(twitterverse_dict, filter_user, present_specific_dict)
    "----------\\na\\nname: John Smith\\nlocation: CA, le32c\\nwebsite: http://haruhi.com\\nbio:\\nHello! This is John Smith\\nSOS\\n\\nfollowing: ['b', 'c']\\n----------\\nc\\nname: zappa kappa\\nlocation: L\\nwebsite: ...\\nbio:\\n\\nfollowing: ['a']\\n----------\\nd\\nname: WATASHI KININARIMASU\\nlocation: zop\\nwebsite: https://www.youtube.com/watch?v=dQw4w9WgXcQ\\nbio:\\nHotaru-san, nandesuka?\\nfollowing: ['a', 'b', 'c']\\n----------\\n"
    
    >>> present_specific_dict = {'sort-by': 'popularity', 'format': 'short'}
    >>> get_present_string(twitterverse_dict, filter_user, present_specific_dict)
    "['c', 'a', 'd']"
    
    >>> present_specific_dict = {'sort-by': 'name', 'format': 'short'}
    >>> get_present_string(twitterverse_dict, filter_user, present_specific_dict)
    "['a', 'd', 'c']"
    """
    
    sort_spec = present_specific_dict['sort-by']
    if 'username' in sort_spec:
        tweet_sort(twitterverse_dict, filter_user, username_first)
    elif 'name' in sort_spec:
        tweet_sort(twitterverse_dict, filter_user, name_first)
    elif 'popularity' in sort_spec:
        tweet_sort(twitterverse_dict, filter_user, more_popular)
        
    seperator = '-' * 10 + '\n'
    present_spec = present_specific_dict['format']
    final = ''
    if present_spec == 'long':
        if not filter_user: # same as if len(filter_user) == 0:
            final += seperator
        for user in filter_user:
            final += seperator + user + '\n'
            profile = twitterverse_dict[user]
            final += get_profile_string(profile)
            # compiles into the format required.
        final += seperator
    elif present_spec == 'short':
        final = str(filter_user) 
    return final
    
# --- Sorting Helper Functions ---

def tweet_sort(twitter_data, results, cmp):
    """ (Twitterverse dictionary, list of str, function) -> NoneType
    
    Sort the results list using the comparison function cmp and the data in 
    twitter_data.
    
    >>> twitter_data = {\
    'a':{'name':'Zed', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'b':{'name':'Lee', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'c':{'name':'anna', 'location':'', 'web':'', 'bio':'', 'following':[]}}
    >>> result_list = ['c', 'a', 'b']
    >>> tweet_sort(twitter_data, result_list, username_first)
    >>> result_list
    ['a', 'b', 'c']
    >>> tweet_sort(twitter_data, result_list, name_first)
    >>> result_list
    ['b', 'a', 'c']
    """
    
    # Insertion sort
    for i in range(1, len(results)):
        current = results[i]
        position = i
        while position > 0 and cmp(twitter_data, results[position - 1], \
                                   current) > 0:
            results[position] = results[position - 1]
            position = position - 1 
        results[position] = current  
            
def more_popular(twitter_data, a, b):
    """ (Twitterverse dictionary, str, str) -> int
    
    Return -1 if user a has more followers than user b, 1 if fewer followers, 
    and the result of sorting by username if they have the same, based on the 
    data in twitter_data.
    
    >>> twitter_data = {\
    'a':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':['b']}, \
    'b':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'c':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':[]}}
    >>> more_popular(twitter_data, 'a', 'b')
    1
    >>> more_popular(twitter_data, 'a', 'c')
    -1
    """
    
    a_popularity = len(all_followers(twitter_data, a)) 
    b_popularity = len(all_followers(twitter_data, b))
    if a_popularity > b_popularity:
        return -1
    if a_popularity < b_popularity:
        return 1
    return username_first(twitter_data, a, b)
    
def username_first(twitter_data, a, b):
    """ (Twitterverse dictionary, str, str) -> int
    
    Return 1 if user a has a username that comes after user b's username 
    alphabetically, -1 if user a's username comes before user b's username, 
    and 0 if a tie, based on the data in twitter_data.
    
    >>> twitter_data = {\
    'a':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':['b']}, \
    'b':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'c':{'name':'', 'location':'', 'web':'', 'bio':'', 'following':[]}}
    >>> username_first(twitter_data, 'c', 'b')
    1
    >>> username_first(twitter_data, 'a', 'b')
    -1
    """
    
    if a < b:
        return -1
    if a > b:
        return 1
    return 0

def name_first(twitter_data, a, b):
    """ (Twitterverse dictionary, str, str) -> int
        
    Return 1 if user a's name comes after user b's name alphabetically, 
    -1 if user a's name comes before user b's name, and the ordering of their
    usernames if there is a tie, based on the data in twitter_data.
    
    >>> twitter_data = {\
    'a':{'name':'Zed', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'b':{'name':'Lee', 'location':'', 'web':'', 'bio':'', 'following':[]}, \
    'c':{'name':'anna', 'location':'', 'web':'', 'bio':'', 'following':[]}}
    >>> name_first(twitter_data, 'c', 'b')
    1
    >>> name_first(twitter_data, 'b', 'a')
    -1
    """
    
    a_name = twitter_data[a]["name"]
    b_name = twitter_data[b]["name"]
    if a_name < b_name:
        return -1
    if a_name > b_name:
        return 1
    return username_first(twitter_data, a, b)

# --- main helper functions ---
def get_clean(twitter_data):
    """(file open for reading) -> list of str
    
    Return a list of all lines within a file with new line removed.
    
    """
    twitter_line = []
    for line in twitter_data:
        twitter_line.append(line.strip())
    return twitter_line

def get_profile(twitter_line, i):
    """(list of str, int, int) -> profile_dict
    
    Return a dictionary matching 'name', 'location' and 'web' keys to values.
    
    >>> twitter_line = ['b','BRIAN', '', '', 'Whose eyes are those eyes?', \
    'ENDBIO', 'c', 'END', 'a', 'John Smith', 'CA le32c', 'http://haruhi.com', \
    'Hello! This is John Smith', 'SOS', '', 'ENDBIO', 'b', 'c', 'END']
    
    >>> get_profile(twitter_line, 0) == {'name': 'BRIAN', 'location': '', \
    'web': ''}
    True
    
    >>> get_profile(twitter_line, 8) == {'name': 'John Smith', \
    'location': 'CA le32c', 'web': 'http://haruhi.com'}
    True
    """
    
    profile = {}
    entries = ['name', 'location', 'web']
    j = 1
    for label in entries:
        profile[label] = twitter_line[i + j]
        j += 1
    return profile

def filter_result(twitterverse_dict, match_users, filter_specific_dict, \
                      entries):
    """(Twitterverse dictionary, list of str, filter specification dictionary) \
       -> list of str

    Precondition: <filter_specific_dict> CANNOT BE AN EMPTY DICTIONARY
    
    Return the usernames that match the specified filter.
    
    >>> twitterverse_dict = {'b': {'name': 'Brian', 'location': '', 'web': '', \
    'following': ['c'], 'bio': 'Whose eyes are those eyes?'}, \
    'c': {'name': 'Charles Kappa', 'location': 'L', 'web': '...', \
    'following': ['a'], 'bio': ''}, 'a': {'name': 'John Smith', \
    'location': 'CA, le32c', 'web': 'http://haruhi.com', \
    'following': ['b', 'c'], 'bio': 'Hello! This is John Smith\\nSOS\\n'}}
    >>> match_users = ['b', 'c']
    >>> filter_specific_dict = {'follower': 'a', 'following': 'a', \
    'location-includes': 'l', 'name-includes': 'a'}
    >>> filter_result(twitterverse_dict, match_users, filter_specific_dict, \
    'follower')
    ['b', 'c']
    """
    
    filter_users = []
    for user in match_users:
        if entries == 'following':
            if filter_specific_dict['following'] in twitterverse_dict[user] \
               ['following']:
                filter_users.append(user)  
                
        elif entries == 'follower':
            if filter_specific_dict['follower'] in \
               all_followers(twitterverse_dict, user):
                filter_users.append(user)
                
        elif entries == 'location-includes':
            if filter_specific_dict['location-includes'].lower() in \
               twitterverse_dict[user]['location'].lower():
                filter_users.append(user)
                
        elif entries == 'name-includes':
            if filter_specific_dict['name-includes'].lower() in \
               twitterverse_dict[user]['name'].lower():
                filter_users.append(user)
        # consideres the 4 possible cases and applies the filter and appends
        # result into a new list.
    return filter_users

def get_profile_string(profile):
    """(profile dictionary) -> str
    
    Return a string with all the components of a profile compiled.
    
    >>> profile = {'name': 'WATASHI KININARIMASU', 'location': 'zop', \
    'web': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', \
    'following': ['a', 'b', 'c'], 'bio': 'Hotaru-san, nandesuka?'}
    >>> get_profile_string(profile)
    "name: WATASHI KININARIMASU\\nlocation: zop\\nwebsite: https://www.youtube.com/watch?v=dQw4w9WgXcQ\\nbio:\\nHotaru-san, nandesuka?\\nfollowing: ['a', 'b', 'c']\\n"
    
    >>> profile = {'name': 'John Smith', 'location': 'CA le32c', \
    'web': 'http://haruhi.com', 'following': ['b', 'c'], \
    'bio': 'Hello! This is John Smith\\nSOS\\n'}
    >>> get_profile_string(profile)
    "name: John Smith\\nlocation: CA le32c\\nwebsite: http://haruhi.com\\nbio:\\nHello! This is John Smith\\nSOS\\n\\nfollowing: ['b', 'c']\\n"
    """
    final =''
    final += 'name: ' + profile['name'] + '\n'
    final += 'location: ' + profile['location'] + '\n'
    final += 'website: ' + profile['web'] + '\n'
    final += 'bio:' + '\n' + profile['bio'] + '\n'
    final += 'following: ' + str(profile['following']) + '\n'
    # compiles the parts of a user profile into a single string.
    return final
    


if __name__ == '__main__':
    import doctest
    doctest.testmod()
