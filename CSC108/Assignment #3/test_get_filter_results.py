import unittest
import twitterverse_functions as tf

class TestGetFilterResults(unittest.TestCase):
    '''Your unittests here'''
    def setUp(self):
        self.twitterverse_dict = {'b': {'name': 'BRIAN', 'location': '', \
                                        'web': '', 'following': ['c'], \
                                        'bio': 'Whose eyes are those eyes?'}, \
                                  'c': {'name': 'charles.kappa', \
                                        'location': 'L', 'web': '...', \
                                        'following': ['a'], 'bio': ''}, \
                                  'a': {'name': 'John Smith', \
                                        'location': 'CA, Le32c', \
                                        'web': 'http://haruhi.com', \
                                        'following': ['b', 'c'], \
                                        'bio': 'This is John Smith\\nSOS\\n'}, \
                                  'd': {'name': 'WATASHI KININARIMASU', \
                                        'location': 'zocp', \
                                        'web': 'https://www.youtube.com', \
                                        'following': ['a', 'b', 'c'], \
                                        'bio': 'Hotaru-san, nandesuka?'}}
        
    def test_filter_example_1(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {} 
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'],{})
        expected = ['a' , 'c', 'd']
        self.assertEqual(actual, expected)
        
    def test_filter_example_2(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {'following': 'a', 'follower': 'b', 'location-includes': 'l', \
        'name-includes': 'a'} 
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], \
                                       {'following': 'a', 'follower': 'b', \
                                        'location-includes': 'l', \
                                        'name-includes': 'a'})
        expected = ['c']
        self.assertEqual(actual, expected)
    
    def test_filter_example_3(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {'following': 'a', 'follower': 'b', 'location-includes': 'L', \
        'name-includes': 'A'}
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], \
                                       {'following': 'a', 'follower': 'b', \
                                        'location-includes': 'L', \
                                        'name-includes': 'A'})
        expected = ['c']
        self.assertEqual(actual, expected)
        
    def test_filter_example_4(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c' ,'d'] \
        and {'following': 'a', 'location-includes': 'c', 'name-includes': 'w'} \
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], \
                                       {'following': 'a', \
                                        'location-includes': 'c', \
                                        'name-includes': 'w'})
        expected = ['d']
        self.assertEqual(actual, expected)
        
    def test_filter_example_5(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {'follower': 'd', 'location-includes': 'l', 'name-includes': 'h'} \
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], \
                                       {'follower': 'd', \
                                        'location-includes': 'l', \
                                        'name-includes': 'h'})
        expected = ['a', 'c']
        self.assertEqual(actual, expected)
        
    def test_filter_example_6(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {'follower': 'c', 'following': 'c', 'name-includes': 'h'}
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], {'follower': 'c', \
                                                         'following': 'c', \
                                                         'name-includes': 'h'})
        expected = ['a']
        self.assertEqual(actual, expected)
        
    def test_filter_example_7(self):
        """ Test get_filter_results with twitterverse_dict, ['a', 'c', 'd'] \
        and {'follower': 'b', 'following': 'c', 'location-includes': 'c'} 
        """
        
        actual = tf.get_filter_results(self.twitterverse_dict, \
                                       ['a', 'c', 'd'], \
                                       {'follower': 'b', 'following': 'c', \
                                        'location-includes': 'c'})
        expected = []
        self.assertEqual(actual, expected)


if __name__ == '__main__':
    unittest.main(exit=False)