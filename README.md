# Simon Game in Elm

This project in a remix of the freeCodeCamp project challenge: https://www.freecodecamp.org/challenges/build-a-simon-game. The intention of this project was to gain a better understanding of how to handle asynchronous side-effects such as timing events using the Elm language and available libraries. This project satisfies the following user stories that are listed under the freeCodeCamp project challenge. Not all features of HTML5 are available in the Elm language so I had to use Elm ports to play the game sounds, for example.

## User Stories

As a user:

- I am presented with a random series of button presses
- Each time I input a series of button presses correctly, I see the same series of button presses but with an additional step
- I hear a sound that corresponds to each button when I click the button and when the series of buttons plays
- If I press the wrong button, I am notified I have done so and the series of button presses starts over
- I can see how many steps are in the current series
- If I want to restart, I can hit a button to do so, and I return to a single step
- I can play strict mode where if I get a button press wrong, the game notifies me and the game restarts the current random series from one
- I can win the game by getting a series of 20 steps correct. I am notified of my victory and I restart with a new random series of buttons presses
