using System.Collections;
using System;

namespace Beef.Linq
{
	public static
	{
		public struct Selector<T, TElem, TSelector, TResult> : IEnumerable<TResult>//, IEnumerator<TResult>
			where T : concrete, IEnumerator<TElem>
			where TSelector : delegate TResult(TElem)
			//where TT: decltype(T.GetEnumerator)
		{
			private static List<List<TResult>> _lists = new .() ~ DeleteContainerAndItems!(_);

			private T _input;
			private List<TResult> _output;
			private TSelector _selector;
			private int state = 0;

			public this(T input, TSelector selector)
			{
				_input = input;
				_output = _lists.Add(..new .());
				_selector = selector;
			}

			public List<TResult>.Enumerator GetEnumerator()
			{
				for (var it in _input)
					_output.Add(_selector(it));

				return _output.GetEnumerator();
			}
		}

		public static Selector<TEnum, TElem, TSelector, TResult> Select<T, TElem, TSelector, TResult, TEnumerator, TEnum>(this T it, TSelector selector, TEnumerator e)
			where T : concrete, IEnumerable<TElem>
			where TSelector : delegate TResult(TElem)
			where TEnumerator : delegate TEnum(T)
			where TEnum : concrete, IEnumerator<TElem>
		{
			return .(e(it), selector);
		}

		public static TElem Sum<T, TElem>(this T items)
			where T : concrete, IEnumerable<TElem>
			where TElem : operator TElem + TElem
		{
			var t = default(TElem);
			for (var it in items)
				t += it;
			return t;
		}

		public static TResult Sum<T, TElem, TResult, TSelector>(this T items, TSelector selector)
			where T : concrete, IEnumerable<TElem>
			where TResult : operator TResult + TResult
			where TResult : operator TResult / TResult
			where TSelector : delegate TResult(TElem)
		{
			var t = default(TResult);
			for (var it in items)
				t += selector(it);
			return t;
		}

		public static TElem Avg<T, TElem>(this T items)
			where T : concrete, IEnumerable<TElem>
			where TElem : operator TElem / int
			where TElem : operator TElem + TElem
		{
			var count = 0;
			var t = default(TElem);
			for (var it in items)
			{
				t += it;
				count++;
			}

			if (count == 0)
				return default(TElem);

			return t / count;
		}

		public static TResult Avg<T, TElem, TResult, TSelector>(this T items, TSelector selector)
			where T : concrete, IEnumerable<TElem>
			where TResult : operator TResult + TResult
			where TResult : operator TResult / int
			where TSelector : delegate TResult(TElem)
		{
			var count = 0;
			var t = default(TResult);
			for (var it in items)
			{
				t += selector(it);
				count++;
			}

			if (count == 0)
				return default(TResult);

			return t / count;
		}

		public static int Count2<T, TElem>(this T items)
			where T : concrete, IEnumerable<TElem>
		{
			//fast
			/*if (let list = items as List<TElem>)
				return list.Count;
			else if (let array = items as TElem[])
				return array.Count;*/

			//slow, .net has a stored `fastOnly` flag in places that will return -1 if it would execute the enumerator
			var count = 0;
			for (var it in items)
				count++;
			return count;
		}

		/*public static void ToList<T, TElem>(this T items, List<TElem> output)
			where T: concrete, IEnumerable<TElem>
		{
			for(var it in items)
				output.Add(it);
		}*/
	}
}
