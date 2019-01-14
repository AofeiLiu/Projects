def process_data(twitter_data):
    """(file open for reading) -> Twitterverse dictionary
    
    Read the file and return the data in the Twitterverse dictionary format. 
    
    """
    twitter_line = twitter_data.readlines()
    # print (twitter_line)
    Twitterverse_dictionary = {}
    for name in get_name(twitter_line):
        print (name)
        #Twitterverse_dictionary[name] = get_profile_dictionary(twitter_line)
    print (Twitterverse_dictionary)
    
def get_profile(twitter_line):
    """(list of str) -> list of list of str
    
    Return the user's profile.
    
    """
    user_profile =[]
    previous_end = twitter_line.index('END\n')
    user_profile.append(twitter_line[1 : previous_end])
    while twitter_line.index('END\n') != len(twitter_line) -1 or twitter_line.index('END\n') != len(twitter_line) -1:
        previous_end = end
        end = twitter_line.index('END\n', previous_end,)
        actual_name = end + 2
        user_profile.append(twitter_line[actual_name : end])
    #print(user_profile)
    return  user_profile

def get_name(twitter_line):
    """(list of str) -> list of str
    
    Return the username.
    
    """
    name_list = [twitter_line[0]]
    i = 0
    for i in range(len(twitter_line)):
        if i != len(twitter_line) - 1 and (twitter_line[i] == 'END' or twitter_line[i] == 'END\n'):
            name_list.append(twitter_line[i + 1])
    return name_list
    

def get_profile_dictionary(twitter_line):
    """ (list of list of str) -> profile dictionary
    
    Return users' profile dictionary.
    
    """
    profile_dictionary = {}
    a = 
    for profile in get_profile(twitter_line):
        profile_dictionary['name'] = profile[0].strip('\n')
        profile_dictionary['location'] = profile[1].strip('\n')
        profile_dictionary['web'] = profile[2].strip('\n')
        profile_dictionary['bio'] = get_bio(twitter_line)
        profile_dictionary['following'] = get_following(twitter_line)
        
    print(profile_dictionary)
            
def get_bio(twitter_line):
    """(list of str) -> str
    
    Return the bio of the user from twitter_data
    
    """
    bio =''
    for profile in get_profile(twitter_line):
        endbio = profile.index('ENDBIO\n')
        for line in twitter_line[3 : endbio]:
            bio += line
    bio = bio.strip('\n')
    return bio

def get_following(twitter_line):
    """(list of str) -> list of str
    
    Return the username the user followed from twitter_data.
    
    """
    user_following =[]
    for profile in get_profile(twitter_line):
        endbio = profile.index('ENDBIO\n')        
        for usernames in twitter_line[endbio + 1 : len(profile)]:
            usernames = usernames.strip('\n')
            user_following.append(usernames)
    return user_following

twitter_data = open('rdata.txt', 'r')
