
To generate an ISO file you need to follow the instructions below:

Here is the instructions:
1. you flash your sd with a fresh raspbian
2. ssh into it
3. run this command:
`curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/get_waziup_test.sh | bash`
4. After installing everything, reboot and make sure everything is ok. First reboot usually takes long time as it pulls images from docker hub
5. Now you test and ready to make ISO image
6. Then you go to ~/waziup-gateway/setup
7. open this file `sd-card-image.sh`
8. Run the commands in the `Prepration` section on top of the file
9. make this file executable
10. create a directory on your PC and share it through samba protocol (in windows it should be just the default sharing directory)
11. Edit the file `sd-card-image.sh` and replace the username of your PC in the file
12. Run the file on the pi with `sudo`

It cleans everything, stops containers and creates the ISO file and moves it to your PC.
