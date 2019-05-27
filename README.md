# Skeleton_piano_kinect
Simple sketch code to use the kinect v1 as a piano

*Required*

- Kinect V1 SDK by Windows installed 
- SimpleOPENNi library
- Sound library
- Processing IDE

*Description*

There are 4 upper circles that plays single notes if touched with a specific hand (hand side = circle side)

Two central circles reproduce two note scales if touched with the same-side hand.

Two lower circles reproduce single notes if touched with the same-side foot.

*Easter egg*

> boolean easter_egg = true/false;

Thi variable is used to activate or deactivate the easter egg hidden in the code.

*Soundfile*

> player = new SoundFile(this, "<whatever_title>.mp3");

The file to be reproduced need to go in the /data folder of the program.
