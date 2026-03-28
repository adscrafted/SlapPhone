#!/bin/bash
# Generate placeholder sounds using macOS text-to-speech
# These can be replaced with professional voice recordings later

SOUNDS_DIR="/Users/anthony/Documents/Projects/SlapPhone/SlapPhone/Resources/Sounds"

# Function to generate a sound file
generate_sound() {
    local dir=$1
    local name=$2
    local text=$3
    local voice=$4
    local rate=${5:-200}

    mkdir -p "$SOUNDS_DIR/$dir"
    say -v "$voice" -r "$rate" -o "$SOUNDS_DIR/$dir/${name}.m4a" "$text"
    echo "Generated: $dir/${name}.m4a"
}

echo "Generating default voice pack (pain sounds)..."
generate_sound "default" "ow1" "Ow!" "Daniel" 250
generate_sound "default" "ow2" "Oww!" "Alex" 280
generate_sound "default" "ouch1" "Ouch!" "Daniel" 220
generate_sound "default" "ouch2" "Ouch, that hurt!" "Alex" 200
generate_sound "default" "oof1" "Oof!" "Daniel" 300
generate_sound "default" "grunt1" "Ungh!" "Alex" 280
generate_sound "default" "argh1" "Argh!" "Daniel" 250
generate_sound "default" "hey1" "Hey!" "Alex" 300

echo "Generating angry voice pack..."
generate_sound "angry" "angry1" "Stop it!" "Daniel" 280
generate_sound "angry" "angry2" "Quit hitting me!" "Alex" 250
generate_sound "angry" "rage1" "I'm warning you!" "Daniel" 260
generate_sound "angry" "rage2" "That's it!" "Alex" 300
generate_sound "angry" "growl1" "Grrr!" "Daniel" 200
generate_sound "angry" "yell1" "Cut it out!" "Alex" 280
generate_sound "angry" "grr1" "I've had enough!" "Daniel" 240
generate_sound "angry" "what1" "What was that for!" "Alex" 260

echo "Generating dramatic voice pack..."
generate_sound "dramatic" "scream1" "Ahhhhh!" "Daniel" 300
generate_sound "dramatic" "scream2" "Nooooo!" "Alex" 280
generate_sound "dramatic" "dramatic1" "The pain! The agony!" "Daniel" 200
generate_sound "dramatic" "dramatic2" "I can't take it anymore!" "Alex" 220
generate_sound "dramatic" "wail1" "Whyyyy!" "Daniel" 180
generate_sound "dramatic" "cry1" "It hurts so much!" "Alex" 200
generate_sound "dramatic" "nooo1" "No no no no no!" "Daniel" 280
generate_sound "dramatic" "whyyy1" "Why would you do this!" "Alex" 220

echo "Generating silly voice pack..."
generate_sound "silly" "boing1" "Boing!" "Fred" 350
generate_sound "silly" "boing2" "Boiiing!" "Fred" 300
generate_sound "silly" "squeak1" "Squeak!" "Samantha" 400
generate_sound "silly" "squeak2" "Eek!" "Samantha" 450
generate_sound "silly" "honk1" "Honk honk!" "Fred" 280
generate_sound "silly" "pop1" "Pop!" "Samantha" 400
generate_sound "silly" "splat1" "Splat!" "Fred" 350
generate_sound "silly" "spring1" "Sproing!" "Samantha" 380

echo "Generating plug sounds (USB moaner)..."
generate_sound "plug" "moan1" "Ooooh!" "Samantha" 150
generate_sound "plug" "ooh1" "Ooh yeah!" "Samantha" 180
generate_sound "plug" "ahh1" "Ahhh!" "Samantha" 160
generate_sound "plug" "sigh1" "Mmmmm!" "Samantha" 140
generate_sound "plug" "gasp1" "Oh!" "Samantha" 250
generate_sound "plug" "oh1" "Oh no!" "Samantha" 200
generate_sound "plug" "huh1" "Huh?" "Samantha" 220
generate_sound "plug" "hmm1" "Hmm." "Samantha" 180

echo ""
echo "Done! Generated all sound files."
echo "Note: These are placeholder TTS sounds. Consider replacing with professional recordings."
