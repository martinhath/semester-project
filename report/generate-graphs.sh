#!/bin/bash

DIR="data"
if [[ ! -d "$DIR" ]]; then mkdir "$DIR"; fi
OUT="plots"
if [[ ! -d "$OUT" ]]; then mkdir "$OUT"; fi
TMP="tmp"
if [[ ! -d "$TMP" ]]; then mkdir "$TMP"; fi

KINDS=`find $DIR -maxdepth 1 | grep -oP "\/\K\w+$"`

function gnuplot_box_threads() {
  # arg1: data file
  # arg2: output file
  # arg3: columns in the file
  # arg4: cpu
  case "$4" in
    "laptop") xtics="('1' 1, '2' 2, '4' 3)" ;;
    "ryzen") xtics="('1' 1, '2' 2, '4' 3, '8' 4, '16' 5)" ;;
    "server") xtics="('1' 1, '2' 2, '4' 3, '8' 4, '12' 5)" ;;
    "scaleway") xtics="('1' 1, '2' 2, '4' 3, '8' 4, '16' 5, '32' 6)" ;;
    "gribb") xtics="('1' 1, '2' 2, '4' 3, '8' 4)" ;;
    *)
      (2>&1 echo "Invalid kind: $4")
      ;;
  esac
  gnuplot <<< "\
set style fill solid 0.25 border -1
set style boxplot outliers pointtype 7
set style data boxplot
# set size square
set key font \",21\"
set xtics $xtics
set pointsize 0.3
set terminal pdf size 10cm,10cm
set termoption font \"Arial,16\"
set output \"$2\"
plot for [i=1:$3] \"$1\" using (i):i notitle
"
}

benches=`find "$DIR" | grep -oP "b:\K[a-zA-Z_]+" | sort | uniq`

function plots_comparing_threads() {
  # Loop over the benchmark sets
  for kind in $(echo "$KINDS"); do
    case $kind in
      "laptop") threads=3 ;;
      "ryzen") threads=5 ;;
      "server") threads=5 ;;
      "scaleway") threads=6 ;;
      "gribb") threads=4 ;;
      *)
        (2>&1 echo "that kind is not valid! $kind")
        exit 1
        ;;
    esac
    DATADIR="$DIR/$kind/"

    # Loop over all benchmarks, since it doesn't make sense to have data from multiple benchmarks in a
    # single plot.
    for bench in $(echo "$benches"); do
      # The files matching this benchmark
      data=`find $DATADIR -name "*$bench*" | sort`
      # All schemes that have this benchmark
      schemes=`echo "$data" | grep -oP "s:\K[a-zA-Z]*(?=-b:)" | uniq`
      # For each of the schemes, find its data files for this benchmark, and merge the thread data into
      # a single file.
      for scheme in $(echo "$schemes"); do
        tmppath="$TMP/$kind-s:$scheme-b:$bench.data"
        outpath="$OUT/$kind-s:$scheme-b:$bench.pdf"
        matchingfiles=`find $DATADIR -name "s:$scheme-b:$bench-*" | sort`
        paste $matchingfiles > "$tmppath"
        gnuplot_box_threads "$tmppath" "$outpath" "$threads" "$kind"
        echo "$kind $bench $scheme"
      done
    done
  done
}

function gnuplot_barplots() {
  # arg1: input file
  # arg2: output file
  # arg3: number of threads in the bench
  # arg4: thread labels
  # arg5: number of schemes
  # arg6: scheme names
  gnuplot <<< "\
set style fill solid 0.25 border -1
set style fill solid
set style data boxes
set boxwidth 0.8
set xtics scale 0 ()
threads=\"$4\"
schemes=\"$6\"
set logscale y 10
set key font \",20\"
set terminal pdf size (10 + $3)cm,10cm
set termoption font \"Arial,20\"
set output \"$2\"
set for  [i=1:$3] xtics add (word(threads, i) (($5 + 1) / 2) + (i - 1) * ($5 + 2))
plot for [i=2:($5 + 1)] \"$1\" using (column(0) * ($5 + 2) + (i-1)):(column(i) -\
  column(1)) title word(schemes, i-1)
"
}

function avg_python() {
  python <<< "
lines = open(\"$1\").readlines()
nums = map(lambda l: int(l), lines)
print(sum(nums)/ len(lines))"
}


function relative_barplots() {
  # Generate a relative clustered bar graph for all benchmarks. The baseline
  # should be `nothing`. It should be a grouped barplot, in which one cluster
  # has the same nubmer of threads, and the bars in the clusters are the
  # schemes.
  # one section for each kind
  for kind in $(echo "$KINDS"); do
    for bench in $(echo "$benches"); do
      case $kind in
        "laptop")   n_threads=3; xtics="1 2 4" ;;
        "ryzen")    n_threads=5; xtics="1 2 4 8 16" ;;
        "server")   n_threads=5; xtics="1 2 4 8 12" ;;
        "scaleway") n_threads=6; xtics="1 2 4 8 16 32" ;;
        "gribb")    n_threads=4; xtics="1 2 4 8" ;;
        *)
          (2>&1 echo "that kind is not valid! $kind")
          exit 1
          ;;
      esac
      # one graph for each bench
      DATADIR="$DIR/$kind"
      data=`find "$DATADIR" -name "*$bench*" | sort`
      all_schemes=`echo "$data" | grep -oP "s:\K[a-zA-Z]*(?=-b:)" | sort | uniq`
      echo "$all_schemes" | grep "nothing" >/dev/null
      a="$?"
      if [[ "$a" =~ 1 ]]; then
        echo "[warn]: skipping $kind $bench, as we're missing 'nothing'."
        continue
      fi
      # We want crossbeam to appear last in the list, but have the others sorted
      if [[ "$all_schemes" =~ 'crossbeam' ]]; then
        all_schemes=`echo "$all_schemes" | grep -v "crossbeam"`$'\ncrossbeam'
      fi
      schemes=`echo "$all_schemes" | grep -v "nothing"`
      threads=`echo "$data" | grep -oP "t:\K\d{2}" | sort | uniq`

      outputfile="$TMP/$kind-b:$bench.avg"
      echo "" > "$outputfile"
      for thread in $(echo "$threads"); do
        for scheme in $(echo "nothing $schemes"); do
          file="$DATADIR/s:$scheme-b:$bench-t:$thread"
          printf "%d " $(avg_python "$file") >> "$outputfile"
        done
        printf "\n" >> "$outputfile"
      done

      outpath="$OUT/$kind-b:$bench.pdf"
      schemes_oneline=`tr '\r\n' ' ' <<< "$schemes"`
      n_schemes=`echo "$schemes" | wc -l `
      gnuplot_barplots "$outputfile" "$outpath" "$n_threads"  "$xtics"\
      "$n_schemes" "$schemes_oneline"
      echo "$outpath"
    done
  done
}

# plots_comparing_threads
relative_barplots
