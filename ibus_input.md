#解决ibus选词bug

cp ~/.cache/ibus/libpinyin/user_bigram.db .

rm -r ~/.cache/ibus/libpinyin/*

mv user_bigram.db ~/.cache/ibus/libpinyin

#重启ibus

ibus-daemon -r -d -x
