using System.Collections;
using System;

namespace Beef.Linq
{
	public static
	{
		public static class Enumerable
		{
			public struct RangeEnumerator<TElem> : IEnumerator<TElem>, IEnumerable<TElem>
				where TElem: operator TElem + int
			{
				TElem mCurrent;
				TElem mEnd;

				public this(TElem start, TElem end)
				{
					mCurrent = start;
					mEnd = end;
				}

				public Result<TElem> GetNext() mut
				{
					if(mCurrent == mEnd)
						return .Err;

					defer { mCurrent = mCurrent + 1; }
					return .Ok(mCurrent);
				}

				public RangeEnumerator<TElem> GetEnumerator()
				{
					return this;
				}
			}

			public static RangeEnumerator<TElem>
				Range<TElem>(TElem count)
				where TElem: operator TElem + int
			{
				return .(default, count);
			}

			public static RangeEnumerator<TElem>
				Range<TElem>(TElem start, TElem end)
				where TElem: operator TElem + int
				where TElem: operator TElem + TElem
			{
				return .(start, end);
			}

		}

		struct SelectEnumerator<TElem, TEnum, TSelect, TResult> : IEnumerator<TResult>, IEnumerable<TResult>
			where TSelect : delegate TResult(TElem)
			where TEnum : concrete, IEnumerator<TElem>
		{
			TSelect mDlg;
			TEnum mEnum;

			public this(TEnum e, TSelect dlg)
			{
				mDlg = dlg;
				mEnum = e;
			}

			public Result<TResult> GetNext() mut
			{
				if (mEnum.GetNext() case .Ok(let val))
					return mDlg(val);

				return .Err;
			}

			public SelectEnumerator<TElem, TEnum, TSelect, TResult> GetEnumerator()
			{
				return this;
			}
		}

		struct WhereEnumerator<TElem, TEnum, TWhere> : IEnumerator<TElem>, IEnumerable<TElem>
			where TWhere : delegate bool(TElem)
			where TEnum : concrete, IEnumerator<TElem>
		{
			TWhere mWhere;
			TEnum mEnum;

			public this(TEnum e, TWhere dlg)
			{
				mWhere = dlg;
				mEnum = e;
			}

			public Result<TElem> GetNext() mut
			{
				while (mEnum.GetNext() case .Ok(let val))
					if (mWhere(val))
						return .Ok(val);

				return .Err;
			}

			public WhereEnumerator<TElem, TEnum, TWhere> GetEnumerator()
			{
				return this;
			}
		}

		struct TakeEnumerator<TElem, TEnum> : IEnumerator<TElem>, IEnumerable<TElem>
			where TEnum : concrete, IEnumerator<TElem>
		{
			TEnum mEnum;
			int mCount;

			public this(TEnum enumerator, int count)
			{
				mEnum = enumerator;
				mCount = count;
			}

			public Result<TElem> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public TakeEnumerator<TElem, TEnum> GetEnumerator()
			{
				return this;
			}
		}

		struct SkipEnumerator<TElem, TEnum> : IEnumerator<TElem>, IEnumerable<TElem>
			where TEnum : concrete, IEnumerator<TElem>
		{
			TEnum mEnum;
			int mCount;

			public this(TEnum enumerator, int count)
			{
				mEnum = enumerator;
				mCount = count;
			}

			public Result<TElem> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(?)) { }

				while (mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public SkipEnumerator<TElem, TEnum> GetEnumerator()
			{
				return this;
			}
		}

	
		public static bool SequenceEquals<TLeft, TRight, TElem>(this TLeft left, TRight right)
			where TLeft : concrete, IEnumerable<TElem>
			where TRight : concrete, IEnumerable<TElem>
			where bool : operator TElem == TElem
		{
			var e0 = left.GetEnumerator();
			var e1 = right.GetEnumerator();
			while (true)
			{
				switch (e0.GetNext()) {
				case .Ok(let i0):
					{
						switch (e1.GetNext()) {
						case .Ok(let i1):
							{
								if (i0 != i1)
									return false;
							}
						case .Err:
							{
								switch (e1.GetNext()) {
								case .Ok:
									return false;
								case .Err:
									return true;
								}
							}
						}
					}
				case .Err:
					{
						switch (e1.GetNext()) {
						case .Ok:
							return false;
						case .Err:
							return true;
						}
					}
				}
			}
		}

		public static SelectEnumerator<TElem, decltype(default(TCollection).GetEnumerator()), TSelect, TResult>
			Select<TCollection, TElem, TSelect, TResult>(this TCollection items, TSelect select)
			where TCollection : concrete, IEnumerable<TElem>
			where TSelect : delegate TResult(TElem)
		{
			return .(items.GetEnumerator(), select);
		}

		public static WhereEnumerator<TElem, decltype(default(TCollection).GetEnumerator()), TWhere>
			Where<TCollection, TElem, TWhere>(this TCollection items, TWhere _where)
			where TCollection : concrete, IEnumerable<TElem>
			where TWhere : delegate bool(TElem)
		{
			return .(items.GetEnumerator(), _where);
		}

		public static TakeEnumerator<TElem, decltype(default(TCollection).GetEnumerator())>
			Take<TCollection, TElem>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TElem>
		{
			return .(items.GetEnumerator(), count);
		}

		public static SkipEnumerator<TElem, decltype(default(TCollection).GetEnumerator())>
			Skip<TCollection, TElem>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TElem>
		{
			return .(items.GetEnumerator(), count);
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

		public static int Count<T, TElem>(this T items)
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

		public static void ToList<T, TElem>(this T items, List<TElem> output)
			where T : concrete, IEnumerable<TElem>
		{
			for (var it in items)
				output.Add(it);
		}
	}
}
