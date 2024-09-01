#!/usr/bin/env bash

resolution_heights=("1080" "720" "360")
default_resolution_height="1080"

input_dir="$(pwd)/go-vid"
output_dir="$(pwd)"

output_static_dir="videos"
output_content_dir="videos"

create() {
	cd "$input_dir"
	read -p "Title: " title
	pub_date=$(date -Iseconds)
	video=$(get_video)

	slug=$(slugify "$title")
	directory_name=$(get_directory_name "$slug")
	
	mkdir "$directory_name"
	cd "$directory_name"

	cp "$video" "video.mp4"
	echo "---" >> description.md
	jq --null-input --arg title "$title" --arg date "$pub_date" '{"title": $title, "date": $date}' | yq -y >> description.md
	echo "---" >> description.md

	"$EDITOR" description.md
}

get_directory_name() {
	discriminator=1
	directory_name="${1}"

	while [ -d "$directory_name" ];
	do
		  discriminator=$((discriminator + 1))
		  directory_name="${1}__${discriminator}"
	done
	echo "$directory_name"
}

get_video() {
	lf -selection-path /dev/stdout
}

transcode() {
	slug="$1"
	cd "$slug"

	output_filename_start="$output_dir/static/$output_static_dir/$slug"

	title_full=$(cat description.md | head -4 | yq -y .title)
	title=$(echo "$title_full" | head -1)
	echo "Transcoding \"$title\"."
	
	for resolution_height in "${resolution_heights[@]}";
	do
		filename="${output_filename_start}_${resolution_height}p.mp4"
		if [ -f "$filename" ];
		then
			echo "${resolution_height}p is already transcoded, skipping."
		else
			echo "Transcoding to ${resolution_height}."
			ffmpeg -i "video.mp4" -filter:v scale=-1:"$resolution_height" -c:v h264_nvenc -c:a copy "$filename"
			
			rm "${filename}.torrent" -f
			mktorrent "$filename" -o "${filename}.torrent"
		fi
	done
	
	cd ..
}

export() {
	slug="$1"
	cd "$slug"
	
	filename="$output_dir/content/$output_content_dir/$slug.md"

	cat description.md | head -n 4 > $filename
	echo "<video src=\"/$output_static_dir/${slug}_${default_resolution_height}p.mp4\" style=\"width: 100%;\" controls=\"true\"></video>" >> $filename
	
	echo "<div>" >> $filename
	echo "<span> Downloads </span>" >> $filename
	echo "<ul>" >> $filename
	for resolution_height in "${resolution_heights[@]}";
	do
		echo "<li><a href=\"/$output_static_dir/${slug}_${resolution_height}p.mp4\" style=\"width: 100%;\" controls=\"true\">${resolution_height}p [Direct]</a></li>" >> $filename
		echo "<li><a href=\"/$output_static_dir/${slug}_${resolution_height}p.mp4.torrent\" style=\"width: 100%;\" controls=\"true\">${resolution_height}p [Torrent]</a></li>" >> $filename
	done
	echo "</ul>" >> $filename
	echo "</div>" >> $filename

	cat description.md | tail -n +5 >> $filename
	
	cd ..
}


if [ "$1" = "create" ];
then
    create
elif [ "$1" = "transcode" ];
then
	cd "$input_dir"
	for video in *;
	do
		transcode "$video"
	done
elif [ "$1" = "export" ];
then
	rm "$output_dir/content/$output_content_dir" -rf
	mkdir -p "$output_dir/content/$output_content_dir"

	cd "$input_dir"
	for video in *;
	do
		export "$video"
	done
fi
