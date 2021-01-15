using System.Threading;

namespace Beef.Linq
{
	typealias IEnumerable<T> = System.Collections.List<T>;

	public class Enumerable
	{
		public struct Selector<T, TElem, TResult>: System.Collections.IEnumerable<TElem>, System.Collections.IEnumerator<TElem>
			where T: IEnumerable<TElem>
			//where TT: decltype(T.GetEnumerator)
		{
			private function TResult(TElem) _selector;
			
			public this(IEnumerable<TElem> items, function TResult(TElem) selector)
			{
				_items = items.GetEnumerator();
				_selector = selector;
			}

			public System.Collections.IEnumerator<TElem> GetEnumerator()
			{
				
				return default;
			}

			public System.Result<TElem> GetNext()
			{
				return default;
			}
		}

		public static IEnumerable<TResult> Select<T, TElem, TSelector, TResult>(this IEnumerable<TElem> it, TSelector selector)
			where T: IEnumerable<TElem>
			where TSelector: delegate TResult(TElem)
		{
			for(var el in it)
			{

			}
		}
	}
}
