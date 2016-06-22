#!/bin/bash

PERCENTILE_NUMBER=95

. "$(dirname "$0")/jmeter-common.sh"

function usage {
  echo "Usage: $(basename "$0") -j test_result"
  echo -e "\t-j\tTest result (.jtl file)"
  exit 1
}

function get_elapsed_time {
  local START_TIME
  START_TIME=$(head -n 1 "$JTL_FILE" | cut -d "," -f1)
  local END_TIME
  END_TIME=$(tail -n 1 "$JTL_FILE" | cut -d "," -f1)
  printf "%.0f" "$(echo "scale=3;($END_TIME - $START_TIME)/1000" | bc)"
}

function print_table_row {
  printf "  %-30s %20s\n" "$1" "$2"
}

while getopts "j:" OPTION
do
  case $OPTION in
    j ) JTL_FILE=$OPTARG;;
    * ) usage;; # Default option
  esac
done

if [[ -z $JTL_FILE ]]; then
  usage
fi

check_that_file_exist "$JTL_FILE"

echo "PERFORMANCE TEST REPORT"

ELAPSED_TIME=$(get_elapsed_time)
HOURS=$(echo "$ELAPSED_TIME / 3600" | bc)
MINUTES=$(echo "($ELAPSED_TIME - ($HOURS * 3600)) / 60" | bc)
SECONDS=$(echo "$ELAPSED_TIME - ($HOURS * 3600) - ($MINUTES * 60)" | bc)
print_table_row "Elapsed time:" "$HOURS h, $MINUTES m, $SECONDS s"

NUMBER_OF_REQUESTS=$(grep -c -e '^[0-9]\{13\},.*$' "$JTL_FILE")
print_table_row "Total number of calls" "$NUMBER_OF_REQUESTS"

CALLS_PER_SECOND=$(printf %.2f "$(echo "scale=4;$NUMBER_OF_REQUESTS / $ELAPSED_TIME" | bc)")
print_table_row "Calls per second" "$CALLS_PER_SECOND"

NUMBER_OF_ERRORS=$(awk -F',' 'int($4)>=400 || $4 ~ /[a-zA-Z]/' "$JTL_FILE" | wc -l)
print_table_row "Number of errors" "$NUMBER_OF_ERRORS"

ERROR_PERCENT=$(printf %.1f "$(echo "scale=3;$NUMBER_OF_ERRORS * 100/ $NUMBER_OF_REQUESTS" | bc)")
print_table_row "Percentage share of errors" "$ERROR_PERCENT %"

IFS=$'\n'
for REQUEST in $(cut -d',' -f3 "$JTL_FILE" | sort | uniq);
do
  unset RESPONSE_TIMES
  unset RESPONSE_TIMES_SORTED
  unset PERCENTILE_ELEMENT

  echo -e "\nRequest: $REQUEST"

  COUNT=$(grep -c ",$REQUEST," "$JTL_FILE")
  print_table_row "Number of calls" "$COUNT"

  # Create an array with the response times and sum the response times
  i=0
  TOTAL=0
  while read RESPONSE_TIME
  do
    RESPONSE_TIMES[i]=$RESPONSE_TIME
    let "i += 1"
    let "TOTAL += $RESPONSE_TIME"
  done < <(grep ",$REQUEST," "$JTL_FILE" | cut -d',' -f2)

  # Calculate average with three decimals and round it to an integer
  AVERAGE=$(printf %.0f "$(echo "scale=3;$TOTAL / $COUNT" | bc)")
  print_table_row "Average response time" "$AVERAGE"

  # Get the percentile
  RESPONSE_TIMES_SORTED=($(echo "${RESPONSE_TIMES[@]}" | sed 's/ /\n/g' | sort -n))
  PERCENTILE_ELEMENT=$(echo "scale=2;$PERCENTILE_NUMBER / 100 * ${#RESPONSE_TIMES_SORTED[@]}" | bc)
  PERCENTILE_ELEMENT_INTEGER_PART=${PERCENTILE_ELEMENT/.*}
  case $(echo "$PERCENTILE_ELEMENT_INTEGER_PART == $PERCENTILE_ELEMENT" | bc) in
    1) ELEMENT=$((PERCENTILE_ELEMENT_INTEGER_PART - 1));;
    0) ELEMENT=$PERCENTILE_ELEMENT_INTEGER_PART;;
  esac
  print_table_row "${PERCENTILE_NUMBER}th percentile" "${RESPONSE_TIMES_SORTED[$ELEMENT]}"

  MIN=${RESPONSE_TIMES_SORTED[0]}
  print_table_row "Min response time" "$MIN"

  MAX=${RESPONSE_TIMES_SORTED[-1]}
  print_table_row "Max response time" "$MAX"

done
unset IFS
