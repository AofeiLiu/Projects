def process_data(twitter_data):
    """(file open for reading) -> Twitterverse dictionary
    
    Read the file and return the data in the Twitterverse dictionary format. 
    
    """
    twitterverse_dictionary = {}
    twitter_line = get_clean(twitter_data)
    i = 0
    while i < len(twitter_line):
        j = 1
        profile = get_profile(twitter_line, i, j)
        # places the 'name', 'location' and 'web' aspects into the profile dict
        j += 3
        bio =''
        while twitter_line[i + j] != 'ENDBIO':
            bio += (twitter_line[i + j]) + '\n'
            j += 1
        # compiles the bio portion of a profile into a single string.
        
        profile['bio'] = bio.strip()
        j += 1
        
        user_following = []
        while twitter_line[i + j] != 'END':
            user_following.append(twitter_line[i + j])
            j += 1
        # compiles usernames within the following section into user_following
        # list.
        profile['following'] = user_following
        
        twitterverse_dictionary[twitter_line[i]] = profile
        i += j + 1

    return twitterverse_dictionary

def get_clean(twitter_data):
    """(file open for reading) -> (list of str)
    
    Return a list of all lines within a file with new line removed.
    
    """
    twitter_line = []
    for line in twitter_data:
        twitter_line.append(line.strip())
    return twitter_line

def get_profile(twitter_line, i, j):
    """(list of str, int, int) -> profile_dict
    
    Return a dictionary matching 'name', 'location' and 'web' keys to values.
    
    """
    profile = {}
    entries = ['name', 'location', 'web']
    for label in entries:
        profile[label] = twitter_line[i + j]
        j += 1
    return profile

twitter_data = open('data.txt','r')
query_data = open('query6.txt','r')

def process_query(query_data):
    """(file open for reading) -> query dicitonary
    
    Read the file and return the query in the query dictionary format.
    
    """
    query_line = []
    for line in query_data:
        query_line.append(line.strip())
    Query_dictionary = {}
    search_dict = {}
    search_dict['username'] = query_line[1]
    search_dict['operations'] = query_line[2 : query_line.index('FILTER')]
    filter_dict = {}
    for line in query_line[query_line.index('FILTER') + 1 : query_line.index('PRESENT')]:
        EMPTY = line.index(' ')
        filter_dict[line[0 : EMPTY]] = line[EMPTY + 1 : len(line)]
    present_dict = {}
    for line in query_line[query_line.index('PRESENT') + 1 : len(query_line)]:
        EMPTY = line.index(' ')
        present_dict[line[0 : EMPTY]] = line[EMPTY + 1 : len(line)]
    
    Query_dictionary['search'] = search_dict
    Query_dictionary['filter'] = filter_dict
    Query_dictionary['present'] = present_dict
    return Query_dictionary

def all_followers(Twitterverse_dictionary, username):
    """(Twitterverse dictionary, str) -> list of str
    
    """
    followers = []
    for users in Twitterverse_dictionary:
        if username in Twitterverse_dictionary[users]['following']:
            followers.append(users)
    return followers


def get_search_results(Twitterverse_dictionary, search_specification_dictionary):
    """(Twitterverse dictionary, search_specification_dictionary) -> list of str
    """
    find_user = search_specification_dictionary['username']
    match_users = [find_user]
    operation_list = search_specification_dictionary['operations']
    match_list = []
    for operation in operation_list:
        match_list = []
        for user in match_users:
            if user in Twitterverse_dictionary:
                if operation == 'following':
                    match_list.extend(Twitterverse_dictionary[user]['following'])
                else:
                    match_list.extend(all_followers(Twitterverse_dictionary, user))
            else:
                match_users = match_users
        match_users = list(set(match_list))
    return match_users

def get_filter_results(Twitterverse_dictionary, match_users, filter_specification_dictionary):
    """(Twitterverse dictionary, list of str, filter specification dictionary) -> list of str
    """
    i = 0
    filter_users = ini_filter_result(Twitterverse_dictionary, match_users, filter_specification_dictionary, i)
    entries = sorted(list(filter_specification_dictionary.keys()))
    if len(entries) > 1:
        for i in range(1, len(entries)):
            filter_users = ini_filter_result(Twitterverse_dictionary, filter_users, filter_specification_dictionary, i)
    return filter_users

def ini_filter_result(Twitterverse_dictionary, match_users, filter_specification_dictionary, i):
    """(Twitterverse dictionary, list of str, filter specification dictionary) -> list of str
    """
    filter_users = []
    entries = sorted(list(filter_specification_dictionary.keys()))
    for user in match_users:
        if entries[i] == 'following':
            if filter_specification_dictionary['following'] == Twitterverse_dictionary[user]['following']:
                filter_users.append(user)
                        
        elif entries[i] == 'follower':
            if filter_specification_dictionary['follower'] == all_followers(Twitterverse_dictionary, user):
                filter_users.append(user)
                        
        elif entries[i] == 'location-includes':
            if filter_specification_dictionary['location-includes'].lower() in Twitterverse_dictionary[user]['location']:
                filter_users.append(user)
                
        elif entries[i] == 'name-includes':
            if filter_specification_dictionary['name-includes'].lower() in Twitterverse_dictionary[user]['name'].lower():
                filter_users.append(user)
    return filter_users
 
    
def get_present_string(Twitterverse_dictionary, filter_users, presentation_specification_dictionary):
    """(Twitterverse dictionary, list of str, presentation specification dictionary) -> str
    """
    present_spec = presentation_specific_dict['sort-by']
    order = filter_user
    if 'username' in present_spec:
        tweet_sort(Twitterverse_dict, filter_user, username_first)
    elif 'name' in present_spec:
        tweet_sort(Twitterverse_dict, filter_user, name_first)
    elif 'popularity' in present_spec:
        tweet_sort(Twitterverse_dict, filter_user, more_popular)
    
        
                    
        
            
                    
                
            
            
        