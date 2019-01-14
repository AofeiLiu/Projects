def process_data(twitter_data):
    """
    """
    twitter_line = twitter_data.readlines()
    profile_dictionary = {}
    Twitterverse_dictionary = {}
    end = twitter_line.index('END\n')
    last_two_end = len(twitter_line) - twitter_line[::-1].index('END\n', end) - 1
    list_bio = get_bio(twitter_line)
    i = 0
    a = 0
    for i in range(last_two_end):
        k = twitter_line.index('END\n', i,)
        for profile in twitter_line[i + 1 : k]:
            profile_dictionary['name'] = profile[i + 1].strip('\n')
            profile_dictionary['location'] = profile[i + 2].strip('\n')
            profile_dictionary['web'] = profile[i + 3].strip('\n')
            profile_dictionary['bio'] = list_bio[a]
            profile_dictionary['following'] = get_following(twitter_line)
            a += 1
            Twitterverse_dictionary[twitter_line[i]] = profile_dictionary
        i = k + 1
    return Twitterverse_dictionary
   
def get_bio(twitter_line):
    """(list of str) -> list of str
    
    Return the bio of the user from twitter_data
    
    """
    bio =[]
    #first_endbio = twitter_line.index('ENDBIO\n')
    inverse_last_endbio = twitter_line[::-1].index('ENDBIO\n')
    last_two_endbio = len(twitter_line) - twitter_line[::-1].index('ENDBIO\n', inverse_last_endbio + 1) - 1
    i = 0
    while i < last_two_endbio:
        a = twitter_line.index('ENDBIO\n', i)
        print (a)
        for line in twitter_line[i + 4 : a]:
            bio.append(line.strip('\n'))
        i = a
    return bio

def get_following(twitter_line):
    """(list of str) -> list of list of str
    
    Return the username the user followed from twitter_data.
    
    """
    user_following =[]
    total_following =[]
    end = twitter_line.index('END\n')
    #first_endbio = twitter_line.index('ENDBIO\n')
    inverse_last_end =twitter_line[::-1].index('END\n')
    last_two_end = len(twitter_line) - twitter_line[::-1].index('END\n', inverse_last_end + 1) -1 
    inverse_last_endbio = twitter_line[::-1].index('ENDBIO\n')
    last_two_endbio = len(twitter_line) - twitter_line[::-1].index('ENDBIO\n', inverse_last_endbio + 1) - 1
    i = 0
    c = 0
    for i in range(last_two_endbio):
        a = twitter_line.index('ENDBIO\n', i)
        for c in range(last_two_end):
            k = twitter_line.index('END\n', c)
            for username in twitter_line[a + 1 : c]:
                username = username.strip('\n')
                user_following.append(username)
                total_following.append(user_following)
        i = a
        c = k
    return total_followiing
twitter_data = open('rdata.txt', 'r')

        
