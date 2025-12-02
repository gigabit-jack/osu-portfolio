# Author:           Josh Goben
# GitHub username:  gigabit-jack
# Date:             21-Nov-2022
# Description:      Defines the classes necessary to play a game of Mancala! Includes the Mancala (game) class and a
#                   Player class. The Mancala class can be used by creating 2 players, then using the play_game method
#                   to select the current player and which of their pits they are starting with. Show the current
#                   board with .print_board() and show the winner with .return_winner().
#
#                   NOTE: Does not enforce Mancala rules for turn taking.

# Start of script
class Player:
    """
    Defines a Player object with a given name. Requires a single parameter for the name, then creates a Player
    store and 6 empty pits. This class returns a Player object which can be used in an instance of the Mancala class.

    Includes methods to get the player name, the store, and a list of the pits values. Can also
    return the value for a specific pit by including its index as an integer (0-5).

    Pits can be modified with the set_player_pits method and providing the pit and increment integer. Store can be
    incremented with the increment_player_store method and a provided integer.
    """

    def __init__(self, player_name):
        self._name = player_name
        self._store = 0
        self._pits = [0, 0, 0, 0, 0, 0]

    def get_player_name(self):
        """
        Returns the player's name
        :return: string
        """
        return self._name

    def get_player_store(self):
        """
        Returns the player's current store value
        :return: int
        """
        return self._store

    def get_player_pits(self, pit_index=None):
        """
        Returns the player's seed count for the given pit, or the entire list if no parameter is entered.
        :param pit_index: int (optional)
        :return: list or int (with parameter)
        """
        if pit_index is not None:
            return self._pits[pit_index]
        else:
            return self._pits

    def set_player_pit(self, pit_index, pit_increment):
        """
        Increments the provided pit by the provided amount. A negative value can be provided for the pit_increment
        to decrement the pit value.
        :param pit_index: int
        :param pit_increment: int
        :return: None
        """
        self._pits[pit_index] = self._pits[pit_index] + pit_increment

    def increment_player_store(self, seeds):
        """
        Increments the player store by the provided integer. Decrements if negative.
        :param seeds: int
        :return: None
        """
        self._store += seeds


class Mancala:
    """
    Defines the Mancala class which creates an instance of a Mancala game. Requires no parameters to create, but
    defaults to using 4 seeds. Accepts an integer parameter to use a different number of seeds.

    Will require the creation of two players with the .create_player method. This method will create a player using
    the Player class and will populate the player's pits with the starting seeds value.

    The Mancala instance can be played with the .play_game method. The method will process all rules of the game,
    update the pits and stores values for each player, and will return the current results at the end of each turn.
    Special rules of Mancala will be observed, such as a player taking another turn by landing in their store.

    The current game board can be printed with the .print_board method, and the winner can be displayed with the
    .return_winner method.
    """

    def __init__(self, starting_seeds=4):
        self._winner = None
        self._seeds_count = starting_seeds
        self._status = "Running"
        self._player1 = None
        self._player2 = None

    def create_player(self, player_name):
        """
        Creates a new player object with the Player class. Requires a single string for a player name. If this is the
        first player, then the Mancala instance will assign the player to player1, otherwise to player2.

        NOTE: Subsequent calls to this method will overwrite player 2 if player 2 had already been created!
        :param player_name: string
        :return: Player object of the Player class
        """
        player = Player(player_name)
        for num in range(0, 6):
            player.set_player_pit(num, self._seeds_count)
        if self._player1 is None:
            self._player1 = player
        else:
            self._player2 = player
        return player

    def print_board(self):
        """
        Will print the current status of the game board. Includes the player's stores and their pits' values by
        querying the Player objects.
        :return: None (prints six lines to console)
        """
        print('player1:')
        print(f"store: {self._player1.get_player_store()}")
        print(self._player1.get_player_pits())
        print('player2:')
        print(f"store: {self._player2.get_player_store()}")
        print(self._player2.get_player_pits())

    def return_winner(self):
        """
        Returns a string with the winner of the game. Will also specify if there is a tie or if the game is not ended.
        :return: string
        """
        if self._status == "Ended":
            # Tie
            if self._winner == "Tie":
                return "It's a tie"
            # Winner
            else:
                return f"Winner is {self._winner[0]}: {self._winner[1].get_player_name()}"
        else:
            # Not ended (Running)
            return "Game has not ended"

    def play_game(self, player_index, pit_index):
        """
        Plays a turn of Mancala. Requires a player number (1 or 2) and a pit number (1-6). During the turn, this method
        will process all game rules and disperse seeds into the correct pits or store and will update those values on
        the corresponding Player objects.

        If a player lands on their own pits, then a message will be displayed telling them to take another turn.

        When the game has ended, a winner will be populated but will not be displayed until using the .return_winner
        method. Any subsequent turns attempted will display an error that the game has ended.

        After a turn has completed - including the final turn - this method will return the current board in a
        list formatted as: player 1 pits 1-6 and store, player 2 pits 1-6 and store.
        Ex. [4, 4, 0, 5, 5, 5, 1, 4, 4, 4, 4, 4, 4, 0]

        NOTE: This method does not validate if the turn follows the turns rules of Mancala.
        :param player_index: int (1-2)
        :param pit_index: int (1-6)
        :return: list of pits and stores for both players
        """
        # check for invalid pit
        if pit_index not in range(1, 7):
            return "Invalid number for pit index"
        elif self._status == "Ended":
            return "Game is ended"
        else:
            # determine current and enemy players
            if player_index == 1:
                current_player = self._player1
                enemy_player = self._player2
            else:
                current_player = self._player2
                enemy_player = self._player1

            pit = pit_index - 1  # set pit index to 0-5 instead of 1-6
            pit_count = current_player.get_player_pits(pit)  # get the current number of seeds in the given pit

            # begin recursive dispersion method
            current_player.set_player_pit(pit, -pit_count)  # set the pick-up pit to zero seeds
            results = self.disperse(player_index, pit + 1, player_index, pit_count)

            # parse the results and return them
            return self.parse_turn_results(results, current_player, player_index, enemy_player)

    def disperse(self, turn_player_index, pit, pit_owner_index, count):
        """
        Recursively disperses the current turn's seeds according to Mancala rules.

        This method is called by the .play_game method and follow the Mancala rules to determine if a seed should be
        deposited in the current pit/store or skipped, then increments the pit/store, decrements the count, and
        continues until the seed count is zero.

        This method will return the final results of the turn after the count has reached zero. Those results are a
        dictionary with the player who's taking the turn, the pit number of the last pit in the turn, and the owner
        of the pit the turn ended on.

        This method does not check for game conditions after the turn is ended, but returns the results to the
        .play_game method.

        :param turn_player_index: int (1 or 2)
        :param pit: int (0-5)
        :param pit_owner_index: int (1 or 2)
        :param count: int
        :return: dictionary - {"player": turn_player_index, "pit": pit, "pit_owner": pit_owner_index}
        """
        # determine who owns the current target pit
        if pit_owner_index == 1:
            pit_owner = self._player1
        else:
            pit_owner = self._player2

        # determine if we are in the store
        if pit == 6:  # if the current pit index is above 5 (0-5) then it is the store
            if pit_owner_index == turn_player_index:  # determine if it's the turn player's pit
                pit_owner.increment_player_store(1)  # increment player's store if so
                count -= 1

                # base case
                if count == 0:  # turn is over, so return a dict of the final results
                    return {"player": turn_player_index, "pit": pit, "pit_owner": pit_owner_index}

            # swap pit_owner index and change sides of the board
            if pit_owner_index == 1:
                pit_owner_index = 2
            else:
                pit_owner_index = 1

            return self.disperse(turn_player_index, 0, pit_owner_index, count)
        else:  # if we're anywhere other than a store (pit == 0-5, or 6)
            pit_owner.set_player_pit(pit, 1)
            count -= 1

            # base case
            if count == 0:  # turn is over, so return a dict of the final results
                return {"player": turn_player_index, "pit": pit, "pit_owner": pit_owner_index}
            else:
                return self.disperse(turn_player_index, pit + 1, pit_owner_index, count)

    def parse_turn_results(self, results, player, player_index, enemy):
        """
        Parses the results of a finished turn and makes changes according to Mancala rules. This method is called by
        the .play_game method and should occur immediately after a .disperse method has completed.

        Checks for three conditions before returning:
        1. Special rule: Capture - if the player has landed on their own pit, and it was previously empty, then the
        player will capture the seeds in the opposing player's pit.
        2. Endgame: If either player has no seeds in any of their pits then the game immediately ends. All remaining
        seeds are placed in the corresponding player's store and the winner is declared by comparing the values of
        both stores.
        3. Special rule: another turn - if the player puts their last seed in their store, then they may take another
        turn. This is printed to the console.

        Regardless of the three checks above, this method will then return the current board state in a list. This list
        is returned to the .play_game method and is in the format: [4, 4, 0, 5, 5, 5, 1, 4, 4, 4, 4, 4, 4, 0].

        :param results: dictionary - the results of the current turn from the .disperse method
        :param player: the current player object
        :param player_index: int - the index value for the current player
        :param enemy: the opposing player object
        :return: list - current state of the board with players pits and stores
        """
        # Special rule - Capture: if you landed on your own pit
        # check if the final pit had been zero and the pit belongs to the current player
        if results["pit"] != 6 and \
                player.get_player_pits(results["pit"]) == 1 and \
                results["pit_owner"] == player_index:
            player.set_player_pit(results["pit"], -1)  # take the one seed out of your final pit
            player.increment_player_store(1)  # add the single seed to your store

            enemy_pit_index = abs(results["pit"] - 5)  # find the corresponding pit on the other side of the board
            enemy_seeds = enemy.get_player_pits(enemy_pit_index)  # get the number of seeds in the enemy pit
            enemy.set_player_pit(enemy_pit_index, -enemy_seeds)  # set the enemy pit to zero seeds
            player.increment_player_store(enemy_seeds)  # add the enemy seeds to your own store

        # Endgame condition: if all pits are empty on either side of board, endgame
        if sum(player.get_player_pits()) == 0 or sum(enemy.get_player_pits()) == 0:

            # move all players seeds to their store
            for num in range(0, 6):  # iterate through each pit one at a time
                player_pit_count = player.get_player_pits(num)  # get the number of seeds in the current pit
                player.increment_player_store(player_pit_count)  # store the seeds in the player's store
                player.set_player_pit(num, -player_pit_count)  # remove the seeds from the current pit

                enemy_pit_count = enemy.get_player_pits(num)
                enemy.increment_player_store(enemy_pit_count)
                enemy.set_player_pit(num, -enemy_pit_count)

            # calculate and set winner
            if self._player1.get_player_store() == self._player2.get_player_store():
                self._winner = "Tie"
            elif self._player1.get_player_store() > self._player2.get_player_store():
                self._winner = ("player 1", self._player1)
            else:
                self._winner = ("player 2", self._player2)

            self._status = "Ended"  # set the status of the game to "Ended"

        # Special rule - Store: if you landed on your own store; final pit will only be 6 if it's yours
        elif results["pit"] == 6:
            print(f"player {player_index} take another turn")

        # regardless of the previous conditions, package and return the results
        turn_results = [num for num in self._player1.get_player_pits()]  # get the player1 pits
        turn_results.append(self._player1.get_player_store())  # append the player1 store
        for num in self._player2.get_player_pits():  # iterate through player2 pits and append
            turn_results.append(num)
        turn_results.append(self._player2.get_player_store())  # append the player2 store

        return turn_results
