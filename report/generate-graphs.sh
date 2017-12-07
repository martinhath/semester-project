#!/bin/bash
# arg1: input directory to find the files from.
# arg2: output file to which we put merged data files, and graphs.
# arg3: number of threads in the data set.

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
  gnuplot <<< "\
set style fill solid 0.25 border -1
set style boxplot outliers pointtype 7
set style data boxplot
set size square
set xlabel 'Number of Threads'
set ylabel 'Time (ns) for the benchmark'
set xtics ('1' 1, '2' 2, '4' 3, '8' 4, '12' 5)
set pointsize 0.3
set terminal pdf size 10cm,10cm
set output \"$2\"
plot for [i=1:$3] \"$1\" using (i):i notitle
"
}

# TODO: search for this dynamically
benches="nop queue_pop queue_push queue_transfer list_remove"

function plots_comparing_threads() {
  # Loop over the benchmark sets
  for kind in $(echo "$KINDS"); do
    case $kind in
      "laptop")
        threads=3
        ;;
      "ryzen")
        threads=5
        ;;
      "server")
        threads=5
        ;;
      *)
        (2>&1 echo "that kind is not valid! $kind")
        exit 1
        ;;
    esac

    # Loop over all benchmarks, since it doesn't make sense to have data from multiple benchmarks in a
    # single plot.
    for bench in $(echo "$benches"); do
      # The files matching this benchmark
      data=`find $DIR -name "*$bench*" | sort`
      # All schemes that have this benchmark
      schemes=`echo "$data" | grep -oP "s:\K[a-zA-Z]*(?=-b:)" | uniq`
      # For each of the schemes, find its data files for this benchmark, and merge the thread data into
      # a single file.
      for scheme in $(echo "$schemes"); do
        echo "kind=$kind bench=$bench scheme=$scheme"
        tmppath="$TMP/$kind-s:$scheme-b:$bench.data"
        outpath="$OUT/$kind-s:$scheme-b:$bench.pdf"
        matchingfiles=`find $DIR -name "s:$scheme-b:$bench-*" | sort`
        paste $matchingfiles > "$tmppath"
        gnuplot_box_threads "$tmppath" "$outpath" "$threads" "$scheme, $bench"
      done
    done
  done
}

plots_comparing_threads
