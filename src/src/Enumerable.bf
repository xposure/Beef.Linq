using System.Collections;

namespace Beef.Linq
{
	//typealias IEnumerable<T> = System.Collections.List<T>;

	public static
	{
		public struct Selector<T, TElem, TSelector, TResult>: IEnumerable<TResult>//, IEnumerator<TResult>
			where T: List<TElem>
			where TSelector: delegate TResult(TElem)
			//where TT: decltype(T.GetEnumerator)
		{
			private static List<List<TResult>> _lists = new .() ~ DeleteContainerAndItems!(_);

			private List<TElem>.Enumerator _enumerator;
			private List<TElem> _input;
			private List<TResult> _output;
			private TSelector _selector;
			
			public this(List<TElem> input, TSelector selector)
			{
				_enumerator = input.GetEnumerator();
				_input = input;
				_output = _lists.Add(.. new .());
				_selector = selector;
			}

			public List<TResult>.Enumerator GetEnumerator()
			{
				for(var it in _input)
					_output.Add(_selector(it));

				return _output.GetEnumerator();
			}

			/*public System.Result<TResult> GetNext() mut
			{
				if(_enumerator.GetNext() case .Ok(let val))
					return .Ok(_selector(val));

				return .Err;
			}*/
		}

		public static Selector<T, TElem, TSelector, TResult> Select<T, TElem, TSelector, TResult>(this T it, TSelector selector)
			where T: List<TElem>
			where TSelector: delegate TResult(TElem)
		{
			return .(it, selector);
		}

		public static void ToList<T, TElem>(this T items, List<TElem> output)
			where T: concrete, IEnumerable<TElem>
		{
			for(var it in items)
				output.Add(it);
		}

	}
}
