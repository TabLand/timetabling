array=( $@ )
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
printf "*******************************************"
clear
perl -MCarp::Always=verbose ${array[0]}
