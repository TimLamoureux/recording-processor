#!/bin/bash

function usage {
    echo "Radio processing script version ${VERSION} by Thimothé Lamoureux aparadox@gmail.com"

    echo "Usage"
}

function echo_params {
    echo "In folder: ${IN}"
    echo "Out folder: ${OUT}"
    echo "Prefix: ${PREFIX}"
    echo "Extension: ${EXT}"
    echo "Days ago: ${DAYS_AGO}"
    echo "Delete originals? ${DELETE_ORIGINALS}"
    echo "Upload files? ${UPLOAD}"
    echo "Google drive folder ${GDRIVE_FOLDER_ID}"

}


function remove_trailing_slash {
    echo $(echo $1 | sed 's:/*$::')
}

function process_params {
    #echo "Processing arguments (total $#)"

    while [ "$1" != "" ]; do
        case "$1" in
            --debug )
                DEBUG=true
                ;;
            -d | --delete)
                DELETE_ORIGINALS=true
                ;;
            -u | --upload)
                UPLOAD=true
                # Check if next arg is not starting with dash (flag)
                if [[ $2 != \-* ]]; then
                    shift
                    GDRIVE_FOLDER_ID=$1
                else
                    >&2 echo "Error: $1 switch requires extra argument (folder ID for Google Drive)."
                    exit 1
                fi
                ;;
            -e | --extension )
                shift
                # TODO: Make sure there is no trailing dot
                EXT=$1
                ;;
            -a | --days_ago )
                shift
                # Checks if $1 is integer
                if [[ $1 =~ ^-?[0-9]+$ ]]; then
                    DAYS_AGO=$1
                else
                    >&2 echo "Error: Argument $1 must be integer. Exiting"
                    exit 1
                fi
                ;;
            -p | --prefix )
                shift
                PREFIX=$1
                ;;
            -h | --help )
                usage
                exit 0
                ;;
            ${*: -2:1} )
                # Next to last Argument is IN folder
                #echo "Next to last arg is ${*: -2:1}"
                IN=$(remove_trailing_slash $1)
                ;;
            ${*: -1:1} )
                # last Argument is OUT folder
                #echo "Last arg is ${*: -1:1}"
                OUT=$(remove_trailing_slash $1)
                ;;
            * )
                usage
                exit 1
                ;;
        esac
        shift
    done
}

function defaults {
    VERSION="1.0"
    GDRIVE_FOLDER_ID="radio-recordings"
    DELETE_ORIGINALS=false
    UPLOAD=false
    EXT="mp3"
    DAYS_AGO=1
    PREFIX=""
    IN=""
    OUT=""
    debug=false
}

function upload {
    if ! [ -x "$(command -v gdrive)" ]; then
        echo 'Error: gdrive is not installed.' >&2
        exit 1
    fi

    # Check if file already exists (NR is 2nd row, $1 is first column)
    FILE_ID=$(gdrive list --query "name = '$1'" | awk 'NR==2{print $1}')

    #echo "Uploading ${OUT}/$1..."
    if [[ $FILE_ID ]]; then
        #echo "File exists: updating ${FILE_ID} with ${OUT}/$1"
        gdrive update $FILE_ID "${OUT}/$1"
    else
        #echo "Uploading initial file ${OUT}/$1"
        gdrive upload -p "${GDRIVE_FOLDER_ID}" --no-progress "${OUT}/$1"
    fi


    # gdrive list --query "name contains 'radio' AND  mimeType = 'application/vnd.google-apps.folder'"
    #gdrive list --query "name = 'SIMA-173.64-20180311.zip'"
}

# set -x

clear
echo "***************************************"
echo "Radio Recordings processing started on $(date)"

defaults
process_params $@

if $debug; then
    echo_params
fi

# Checking for existence of IN directory
if [[ ! -d $IN ]]; then
    >&2 echo "Error: IN folder $1 could not be found. Exiting"
    exit 1
fi

# Processing OUT directory, create if doesn't exist
if [[ ! -e ${OUT} ]]; then
    echo "Creating directory ${OUT}"
    mkdir "${OUT}"
elif [[ ! -d ${OUT} ]]; then
    >&2 echo "Error: ${OUT} already exists but is not a directory, Exiting"
    exit 1
fi


# Day is used for filtering audio files and archives file names
day=$(date -d "${DAYS_AGO} days ago" '+%Y%m%d')

find "${IN}" -name "${PREFIX}*${EXT}" -daystart -mtime "${DAYS_AGO}" -print0 | sort -z | while IFS= read -r -d '' recording; do
    #echo "$recording"
    #echo $(stat -c %Y ${recording})
    #echo $(stat -c %y ${recording})
    # Remove 3600 seconds from last modification to get creation time
    mdate=$(date -d "@$(($(stat -c %Y ${recording})-3600))" '+%Y%m%d_%H00')
    new_file="${PREFIX}${mdate}.${EXT}"
    cp "$recording" "${OUT}/${new_file}"

    if $DELETE_ORIGINALS; then
        rm "$recording"
    fi
done
# Compress recursive, list files, best compression

#echo "Looking for files in ${OUT} with name pattern ${NAME}"
FILES=$(find $OUT -type f -name "${PREFIX}${day}*.${EXT}")
#echo "Found files: ${FILES}"
if [ ! -z "${FILES}" ]; then
    ARCHIVE="${PREFIX}${day}.zip"
    (cd "${OUT}" && zip -q9m -P "1DSleZOzguIGl3WOMozws3Ao5OoEX46h5xS850jf992fOIQA" "$ARCHIVE" ${PREFIX}${day}*.${EXT}) && echo "Archive ${OUT}/${ARCHIVE} generated." || "Error"

    if [ $UPLOAD ]; then
        upload "${ARCHIVE}"
    fi
else
    >&2 echo "Warning: No files to archive. Stopping"
    exit 0
fi

echo "End of recording-processor - Job completed sucessfully."
exit 0
