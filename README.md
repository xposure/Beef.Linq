# Beef.Linq

# Matching
 - [x] `public static bool All<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate);`
 - [x] `public static bool Any<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate);`
 - [x] `public static bool Any<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static bool Contains<TSource>(this IEnumerable<TSource> source, TSource value);`
 - [x] `public static bool SequenceEqual<TSource>(this IEnumerable<TSource> first, IEnumerable<TSource> second);`

# Aggregates
 - [x] `public static TResult Average<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TResult Max<TResult>(this IEnumerable<TResult> source);`
 - [x] `public static TResult Min<TResult>(this IEnumerable<TResult> source);`
 - [x] `public static TResult Sum<TResult>(this IEnumerable<TResult> source);`
 - [x] `public static int Count<TSource>(this IEnumerable<TSource> source);`


# Find in enumerable
 - [x] `public static TSource ElementAt<TSource>(this IEnumerable<TSource> source, int index);`
 - [x] `public static TSource ElementAtOrDefault<TSource>(this IEnumerable<TSource> source, int index);`
 - [x] `public static TSource First<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TSource FirstOrDefault<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TSource Last<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TSource LastOrDefault<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TSource Single<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static TSource SingleOrDefault<TSource>(this IEnumerable<TSource> source);`

# Enumerable Chains
 - [x] `public static IEnumerable<int> Range(int start, int count);`
 - [x] `public static IEnumerable<TSource> DefaultIfEmpty<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static IEnumerable<TSource> DefaultIfEmpty<TSource>(this IEnumerable<TSource> source, TSource defaultValue);`
 - [x] `public static IEnumerable<TSource> Distinct<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static IEnumerable<TResult> Empty<TResult>();`
 - [x] `public static IEnumerable<TResult> Repeat<TResult>(TResult element, int count);`
 - [x] `public static IEnumerable<TSource> Reverse<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static IEnumerable<TResult> Select<TSource, TResult>(this IEnumerable<TSource> source, Func<TSource, TResult> selector);`
 - [x] `public static IEnumerable<TSource> Skip<TSource>(this IEnumerable<TSource> source, int count);`
 - [x] `public static IEnumerable<TSource> SkipWhile<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate);`
 - [x] `public static IEnumerable<TSource> Take<TSource>(this IEnumerable<TSource> source, int count);`
 - [x] `public static IEnumerable<TSource> TakeWhile<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate);`
 - [x] `public static IEnumerable<TSource> Where<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate);`

# ToXYZ
 - [x] `public static Dictionary<TKey, TSource> ToDictionary<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector);`
 - [x] `public static Dictionary<TKey, TElement> ToDictionary<TSource, TKey, TElement>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TSource, TElement> elementSelector);`
 - [x] `public static HashSet<TSource> ToHashSet<TSource>(this IEnumerable<TSource> source);`
 - [x] `public static List<TSource> ToList<TSource>(this IEnumerable<TSource> source);`


# Aggregate
 - [x] `public static TSource Aggregate<TSource>(this IEnumerable<TSource> source, Func<TSource, TSource, TSource> func);`
 - [x] `public static TAccumulate Aggregate<TSource, TAccumulate>(this IEnumerable<TSource> source, TAccumulate seed, Func<TAccumulate, TSource, TAccumulate> func);`
 - [x] `public static TResult Aggregate<TSource, TAccumulate, TResult>(this IEnumerable<TSource> source, TAccumulate seed, Func<TAccumulate, TSource, TAccumulate> func, Func<TAccumulate, TResult> resultSelector);`

# GroupBy
 - [ ] `public static IEnumerable<IGrouping<TKey, TSource>> GroupBy<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector);`
 - [ ] `public static IEnumerable<TResult> GroupBy<TSource, TKey, TResult>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TKey, IEnumerable<TSource>, TResult> resultSelector);`
 - [ ] `public static IEnumerable<TResult> GroupBy<TSource, TKey, TElement, TResult>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TSource, TElement> elementSelector, Func<TKey, IEnumerable<TElement>, TResult> resultSelector);`
 - [ ] `public static IEnumerable<IGrouping<TKey, TElement>> GroupBy<TSource, TKey, TElement>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TSource, TElement> elementSelector);`
 - [ ] `public static IEnumerable<TResult> GroupJoin<TOuter, TInner, TKey, TResult>(this IEnumerable<TOuter> outer, IEnumerable<TInner> inner, Func<TOuter, TKey> outerKeySelector, Func<TInner, TKey> innerKeySelector, Func<TOuter, IEnumerable<TInner>, TResult> resultSelector);`

# Intersect
 - [x] `public static IEnumerable<TSource> Intersect<TSource>(this IEnumerable<TSource> first, IEnumerable<TSource> second);`
 
# Join
 - [ ] `public static IEnumerable<TResult> Join<TOuter, TInner, TKey, TResult>(this IEnumerable<TOuter> outer, IEnumerable<TInner> inner, Func<TOuter, TKey> outerKeySelector, Func<TInner, TKey> innerKeySelector, Func<TOuter, TInner, TResult> resultSelector);`

# ToLookup
 - [ ] `public static ILookup<TKey, TSource> ToLookup<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector);`
 - [ ] `public static ILookup<TKey, TElement> ToLookup<TSource, TKey, TElement>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TSource, TElement> elementSelector);`

# Union
 - [x] `public static IEnumerable<TSource> Union<TSource>(this IEnumerable<TSource> first, IEnumerable<TSource> second);`

# SelectMany
 - [ ] `public static IEnumerable<TResult> SelectMany<TSource, TCollection, TResult>(this IEnumerable<TSource> source, Func<TSource, IEnumerable<TCollection>> collectionSelector, Func<TSource, TCollection, TResult> resultSelector);`
 - [ ] `public static IEnumerable<TResult> SelectMany<TSource, TResult>(this IEnumerable<TSource> source, Func<TSource, IEnumerable<TResult>> selector);`

# ThenBy
 - [ ] `public static IOrderedEnumerable<TSource> ThenBy<TSource, TKey>(this IOrderedEnumerable<TSource> source, Func<TSource, TKey> keySelector, IComparer<TKey> comparer);`
 - [ ] `public static IOrderedEnumerable<TSource> ThenBy<TSource, TKey>(this IOrderedEnumerable<TSource> source, Func<TSource, TKey> keySelector);`
 - [ ] `public static IOrderedEnumerable<TSource> ThenByDescending<TSource, TKey>(this IOrderedEnumerable<TSource> source, Func<TSource, TKey> keySelector, IComparer<TKey> comparer);`
 - [ ] `public static IOrderedEnumerable<TSource> ThenByDescending<TSource, TKey>(this IOrderedEnumerable<TSource> source, Func<TSource, TKey> keySelector);`

# OrderBy
 - [x] `public static IOrderedEnumerable<TSource> OrderBy<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector);`
 - [x] `public static IOrderedEnumerable<TSource> OrderByDescending<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector);`

# Merging
 - [x] `public static IEnumerable<TSource> Prepend<TSource>(this IEnumerable<TSource> source, TSource element);`
 - [x] `public static IEnumerable<TSource> Concat<TSource>(this IEnumerable<TSource> first, IEnumerable<TSource> second);`
 - [x] `public static IEnumerable<TSource> Append<TSource>(this IEnumerable<TSource> source, TSource element);`

# Utils
 - [x] `public static IEnumerable<TSource> Except<TSource>(this IEnumerable<TSource> first, IEnumerable<TSource> second);`
 - [x] `public static IEnumerable<TResult> Zip<TFirst, TSecond, TResult>(this IEnumerable<TFirst> first, IEnumerable<TSecond> second, Func<TFirst, TSecond, TResult> resultSelector);`

