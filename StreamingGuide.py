# Author:           Josh Goben
# GitHub username:  gigabit-jack
# Date:             6/1/22
# Description:      Defines a class for a movie, a streaming service, and a streaming guide. Movie objects can be added
#                   to each streaming service, and the streaming guide will query the various services to find where
#                   you can watch a given movie.

# Start of script

class Movie:
    """
    Create a movie object with a title, genre, director, and year.
    """

    def __init__(self, title, genre, director, year):
        """
        Initializes the movie object and the four required parameters.
        :param title: name of the movie
        :param genre: genre of the movie
        :param director: director of the movie
        :param year: original release year of the movie
        """
        # I was worried about the types since it was called out in the assignment, otherwise I wouldn't be casting here.
        self._title = str(title)
        self._genre = str(genre)
        self._director = str(director)
        self._year = int(year)

    def get_title(self):
        """
        :return: title of the movie
        """
        return self._title

    def get_genre(self):
        """
        :return: genre of the movie
        """
        return self._genre

    def get_director(self):
        """
        :return: director of the movie
        """
        return self._director

    def get_year(self):
        """
        :return: release year of the movie
        """
        return self._year


class StreamingService:
    """
    Defines a streaming service object which can contain movie objects.
    """

    def __init__(self, name):
        """
        Initializes a streaming service with the given name and creates an empty catalog of movies.
        :param name: Name of the streaming service
        """
        self._name = name
        self._catalog = dict()  # dictionary key = movie title, value = Movie object

    def get_name(self):
        """
        :return: returns the name of the streaming service
        """
        return self._name

    def get_catalog(self):
        """
        :return: returns the complete catalog (dictionary type) of movies in the streaming service
        """
        return self._catalog

    def add_movie(self, movie_object):
        """
        Adds an existing movie object to the streaming service.
        :param movie_object: the actual movie object itself
        """
        self._catalog[movie_object.get_title()] = movie_object

    def delete_movie(self, movie_title_to_remove):
        """
        Deletes an existing movie object from the streaming service if it is already in the catalog.
        :param movie_title_to_remove: The name of the movie to remove
        """
        if movie_title_to_remove in self._catalog:
            self._catalog.pop(movie_title_to_remove)


class StreamingGuide:
    """
    Defines a Streaming Guide object which will allow querying for a movie title and returns the names of
    streaming services which can play the title.
    """

    def __init__(self):
        """
        Initializes the object and creates an empty list of services
        """
        self._list_of_services = []

    def add_streaming_service(self, streaming_service_object):
        """
        Adds an existing streaming service object to the guide.
        :param streaming_service_object: The actual streaming service object to be added.
        """
        self._list_of_services.append(streaming_service_object)

    def delete_streaming_service(self, streaming_service_name):
        """
        Deletes an existing streaming service object from the guide if it is already in the list.
        :param streaming_service_name: The actual streaming service object to be removed.
        """
        if streaming_service_name in self._list_of_services:
            self._list_of_services.remove(streaming_service_name)

    def where_to_watch(self, movie_title):
        """
        Accepts a movie title (string) and queries all the streaming services added to this guide for that movie.
        :param movie_title: The name of the movie to search for.
        :return: Returns a list of the movie title, year, and all the services where it can be watched.
        """
        list_of_valid_services = []  # create a set of streaming services which contain the given movie_title
        for streaming_service in self._list_of_services:
            if movie_title in streaming_service.get_catalog():
                list_of_valid_services.append(streaming_service)  # adds the streaming service to the list

        if len(list_of_valid_services) == 0:
            return None  # returns None if there are no valid streaming services
        else:
            movie_object = list_of_valid_services[0].get_catalog()[movie_title]  # references the movie object

            # starts the resulting list by getting the title and year of the movie and adding to the list
            resultant_list = [movie_object.get_title() + " (" + str(movie_object.get_year()) + ")"]

            # iterates through each service and appends the name to the resultant_list
            for service in list_of_valid_services:
                resultant_list.append(service.get_name())

            return resultant_list
