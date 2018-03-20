# recording-processor
This application batch processes radio recording files for RTL-SDR-Airband. It fetches all the recording from a day, moves and renames them in the *out* folder, bundles them in a zip file and optionally upload them to Google Drive. 

Note: This script has been put together quickly and could benefit from additional testing. Security could be improved for the zipped files but achieves a good balance between protection and ease of use for non-technical users of the archives.

##Requirements

###Radio Recordings
All the original radio recordings should be stored in the same folder (*in*). When dealing with multiple frequencies, a prefix should be used to group the recordings together. A date stamp is not required in the filename as the script uses the files last modification date. However, marking the originals with a timestamp can make it much easier to see what is going on and retrieve the originals.

Example filename for an original recording: 173.64-20180309_09. In this example, the prefix is the radio frequency recorded (173.64) followed by the time stamp.


###Google Drive CLI Client (gdrive)
This utility provides the ability to upload the recordings to Google Drive.
[**Project home page**](https://github.com/prasmussen/gdrive) 

##Installation
Simply clone this project in a folder. Optionally, install Google Drive CLI and configure it for use with a Google Drive account (follow projects instructions).

If you decide to automate the recording processing, create a CRON Job to run every day.

	crontab -e

##
##Usage
Simplest form

	./radio-test.sh [path-to-originals] [path-to-processed]
	
[path-to-originals] is where the recordings are sourced from

[path-to-processed] is where the renamed files will be moved to and zipped

##Flags
	-a | --days_ago [X]
This flag will fetch and process the recordings for X days ago. The script uses "daystart" to make sure only the files for one entire day are processed. 

	-d | --delete
This flag will delete the original recordings once they have been processed. Helps in keeping your folders clean.

	--debug
This flag shows debugging information as the program is run.

	-h | --help
The manual and help section are not written in the current implementation.

	-p | --prefix
The prefix for the original files. Allows processing of multiple recorded frequencies stored in one folder. The prefix is also prepended to the processed zip file.

	-u | --upload [gdrive folder ID]
This flag will connect to Google Drive and upload the zipped file into the folder specified by ID.

## Example
	./recording-processor.sh -u 1STMc4lIfTMqL-Z-Ujq1w3ev-jWmi0o72 -e mp3 --days_ago 9 -p 'SIMA-173.64-' /home/tim/Desktop/radio-recordings/ /home/tim/Desktop/processed-recordings/ >> ~/Desktop/radio.log 2>&1



##Roadmap
For the time being, we do not plan on adding these features to the script. They are listed as a reference if someone wants to update this script.

- Ability to select Google Drive folders by name instead of by ID
- Chose between zip and tar.gz for compression
- Better encryption of the archive
- Add new Cloud Storage providers
- Write help section in script