#!/usr/bin/zsh

if [[ -z $1 ]] || [[ ! -d $1 ]]; then
	echo "Usage:\n$0 folder" >&2
	exit 1
fi

foldersToCopy=(etc/systemd etc/security/limits.d)

function needCopy()
{
	file=$1
	for folder in $foldersToCopy
	do
		#echo "file=$file, folder=$folder"
		if [[ $file = ${folder}* ]]; then
			return 0
		fi
	done
	return 1
}

untrackedFiles=$(git status -uall --short --porcelain | awk '$1==''"??"'' {print $2}')


cd $1
for file in **/*(.)
do
	bn=$(basename $file)
	if [[ install.sh  = $bn ]]; then
		echo "skip install file"
		continue
	fi

	if (( ${untrackedFiles[(Ie)$file]} )); then
		echo "skip untracked file: $file"
		continue
	fi

	if needCopy $file ; then
		# echo "copy $file"
		cp $PWD/$file /$file
	else
		# echo "link $file"
		ln -s $PWD/$file /$file
	fi
done
