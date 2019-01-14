def process_data(twitter_data):
    """(file open for reading) -> Twitterverse dictionary
    
    Read the file and return the data in the Twitterverse dictionary format. 
    
    """
    twitter_line = twitter_data.readlines()
    #print (twitter_line)
    #print(len(twitter_line))
    #end = twitter_line.index('END\n')
    #print(end)
    #profiles = [twitter_line[:end]]
    #print(profiles)
    #profiles = []
    #strip_end(twitter_line)
    end 
    previous_end = end
    while previous_end <= len(twitter_line):
        end = twitter_line.index('END\n', end + 1,)
        if end != ValueError:
            end = twitter_line.index('END\n', previous_end + 1,)
        #print(end)
            profiles.extend(twitter_line[previous_end + 1 : end])
    #Twitterverse_dictionary = {}
    #Twitterverse_dictionary[twitter_line[0].strip('\n')] = get_user(twitter_line)
    #Twitterverse_dictionary['username'] = twitter_line[0].strip('\n')
    #print (Twitterverse_dictionary)
    
def strip_end(twitter_line):
    """
    """
    end_ind = 0
    while end_ind < len(twitter_line) - 1:
        end_ind = twitter_line.index('END\n')
        twitter_line[end_ind] = twitter_line[end_ind].strip('\n')

def get_user(twitter_line):
    """(list of str) -> user_dictionary
    
    Return user data dictionary
    
    """
    user_dictionary = {}
    user_dictionary['name'] = twitter_line[1].strip('\n')
    user_dictionary['location'] = twitter_line[2].strip('\n')
    user_dictionary['web'] = twitter_line[3].strip('\n')
    user_dictionary['bio'] = get_bio(twitter_line)
    user_dictionary['following'] = get_following(twitter_line)
    return user_dictionary
    
def get_bio(twitter_line):
    """(list of str) -> str
    
    Return the bio of the user from twitter_data
    
    """
    bio =''
    endbio = twitter_line.index('ENDBIO\n')
    for line in twitter_line[4 : endbio]:
        bio += line
    bio = bio.strip('\n')
    return bio

def get_following(twitter_line):
    """(list of str) -> list of str
    
    Return the username the user followed from twitter_data.
    
    """
    user_following =[]
    end = twitter_line.index('END\n')
    endbio = twitter_line.index('ENDBIO\n')
    for usernames in twitter_line[endbio + 1 : end]:
        usernames = usernames.strip('\n')
        user_following.append(usernames)
    return user_following
    
twitter_data = open('rdata.txt', 'r')
query_data = open('query5.txt', 'r')

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
      