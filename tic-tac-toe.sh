#!/bin/bash

declare -a board

rows=3
columns=3

empty=0
x_player=1
o_player=2

function initialize_matrix {
  local max=$((rows*columns))

    for ((i=0; i<max; i++)); do
        board[$i]=$empty
    done
}

function print_guide {
    echo "------------------------------------GUIDE------------------------------------"
    echo "The board is numbered as follows:"
    echo " 1 | 2 | 3 "
    echo "-----------"
    echo " 4 | 5 | 6 "
    echo "-----------"
    echo " 7 | 8 | 9 "

    echo "To make a move, enter the number of the place you want to put your symbol in"
    echo "-----------------------------------------------------------------------------"
}

function print_matrix {
    echo "------------------------------------BOARD------------------------------------"

    for ((i=0; i<rows; i++)); do
      print_row "$i"
      if [ "$i" -ne $((rows-1)) ]; then
        echo "-----------"
      fi
    done

    echo "-----------------------------------------------------------------------------"
}

function print_row {
    local row=$i

    for ((j=0; j<columns; j++)); do
        local current_place=$((row*columns+j))

        print_symbol ${board[$current_place]}

        if [ "$j" -ne $((columns-1)) ]; then
            echo -n "|"
        fi
    done

    echo ""
}

function print_symbol {
    local symbol=$1

    if [ "$symbol" -eq $empty ]; then
        echo -n "   "
    elif [ "$symbol" -eq $x_player ]; then
        echo -n " X "
    elif [ "$symbol" -eq $o_player ]; then
        echo -n " O "
    fi
}

# TODO: Implement this function based on the game rules with the current board state (1D array)
function check_winner {
  echo "Checking winner..."
}

function player_move {
  local player=$1
  local command=""

  echo "Player $player's turn - enter a place to put your symbol in (or type 'help' to get help): "
  read -r command

  if [ "$command" = "help" ]; then
    print_guide
    player_move "$player"
    return
  fi

  re='^[1-9]$'

  if ! [[ $command =~ $re ]] ; then
    echo "Provided value is invalid, please provide a number from 1 to 9" >&2;
    player_move "$player"
    return
  fi

  local place=$((command-1))

  if [ ${board[$place]} -ne $empty ]; then
    echo "This place is already taken, please choose another one"
    player_move "$player"
    return
  fi

  board[$place]=$player

  print_matrix

  check_winner "$player"
}

function play_game {
  while true; do
    player_move $x_player
    player_move $o_player
  done
}

echo "Hello, welcome to Tic-Tac-Toe game!"

initialize_matrix
play_game
