using System.Collections;
using System;
using internal System.Linq;

namespace System.Linq
{
	public static
	{
		public static class Enumerable
		{
			public struct RangeEnumerator<TSource> : IEnumerator<TSource>, IEnumerable<TSource>
				where TSource : operator TSource + int
			{
				TSource mCurrent;
				TSource mEnd;

				public this(TSource start, TSource end)
				{
					mCurrent = start;
					mEnd = end;
				}

				public Result<TSource> GetNext() mut
				{
					if (mCurrent == mEnd)
						return .Err;

					defer { mCurrent = mCurrent + 1; }
					return .Ok(mCurrent);
				}

				public Self GetEnumerator()
				{
					return this;
				}
			}

			public static RangeEnumerator<TSource>
				Range<TSource>(TSource count)
				where TSource : operator TSource + int
			{
				return .(default, count);
			}

			public static RangeEnumerator<TSource>
				Range<TSource>(TSource start, TSource end)
				where TSource : operator TSource + int
				where TSource : operator TSource + TSource
			{
				return .(start, end);
			}
		}

		#region Matching
		public static bool All<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): if (!predicate(val)) return false;
				case .Err: return false;
				}

				while (enumerator.GetNext() case .Ok(let val))
					if (!predicate(val))
						return false;

				return true;
			}
		}

		public static bool Any<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			for (var it in items)
				return true;

			return false;
		}

		public static bool Any<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			for (var it in items)
				if (predicate(it))
					return true;

			return false;
		}

		/*
		public static bool Contains<TCollection, TSource>(this TCollection items, TSource source)
			where TCollection : concrete, IEnumerable<TSource>
			where bool: operator TSource == TSource
		{
			var enumerator = items.GetEnumerator();
			while (enumerator.GetNext() case .Ok(let val))
				if(val == source)
					return true;

			return false;
		}
		*/

		public static bool SequenceEquals<TLeft, TRight, TSource>(this TLeft left, TRight right)
			where TLeft : concrete, IEnumerable<TSource>
			where TRight : concrete, IEnumerable<TSource>
			where bool : operator TSource == TSource
		{
			using(let iterator0 = Iterator<decltype(default(TLeft).GetEnumerator()), TSource>(right.GetEnumerator()))
			using(let iterator1 = Iterator<decltype(default(TRight).GetEnumerator()), TSource>(right.GetEnumerator()))
			{
				var e0 = iterator0.mEnum;
				{
					var e1 = iterator1.mEnum;
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
			}
		}

		#endregion

		#region Aggregates


		public static TSource Average<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : operator TSource / int
			where TSource : operator TSource + TSource
		{
			var count = 0;
			TSource sum = ?;
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;

				switch (enumerator.GetNext())
				{
				case .Ok(let val):
					sum = val;
					count++;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					sum += val;
					count++;
				}

				return sum / count;
			}
		}

		public static TResult Average<TCollection, TSource, TResult, TSelect>(this TCollection items, TSelect selector)
			where TCollection : concrete, IEnumerable<TSource>
			where TResult : operator TResult + TResult
			where TResult : operator TResult / int
			where TSelect : delegate TResult(TSource)
		{
			var count = 0;
			TResult sum = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val):
					sum = selector(val);
					count++;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					sum += selector(val);
					count++;
				}
			}

			return sum / count;
		}

		public static TSource Max<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
		{
			TSource max = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): max = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = val;
					if (max < next)
						max = next;
				}
			}
			return max;
		}

		public static TResult Max<TCollection, TSource, TResult, TSelect>(this TCollection items, TSelect selector)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TResult < TResult
			where TSelect : delegate TResult(TSource)
		{
			TResult max = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): max = selector(val);
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = selector(val);
					if (max < next)
						max = next;
				}
			}
			return max;
		}

		public static TSource Min<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
		{
			TSource min = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): min = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = val;
					if (next < min)
						min = next;
				}
			}
			return min;
		}

		public static TResult Min<TCollection, TSource, TResult, TSelect>(this TCollection items, TSelect selector)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TResult < TResult
			where TSelect : delegate TResult(TSource)
		{
			TResult min = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): min = selector(val);
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = selector(val);
					if (next < min)
						min = next;
				}
			}
			return min;
		}

		public static TSource Sum<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : operator TSource + TSource
		{
			TSource sum = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): sum = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
					sum += val;
			}
			return sum;
		}

		public static TResult Sum<TCollection, TSource, TResult, TSelect>(this TCollection items, TSelect selector)
			where TCollection : concrete, IEnumerable<TSource>
			where TResult : operator TResult + TResult
			where TResult : operator TResult / TResult
			where TSelect : delegate TResult(TSource)
		{
			TResult sum = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): sum = selector(val);
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
					sum += selector(val);
			}
			return sum;
		}

		public static int Count<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			var count = 0;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				while (enumerator.GetNext() case .Ok)
					count++;
			}
			return count;
		}

		#endregion

		#region Find in enumerable


		#endregion

		struct Iterator
		{
			public static Iterator<decltype(default(TCollection).GetEnumerator()), TSource> Wrap<TCollection, TSource>(TCollection items)
				where TCollection : concrete, IEnumerable<TSource>
			{
				return .(items.GetEnumerator());
			}
		}

		struct Iterator<TEnum, TSource> : IDisposable
			where TEnum : concrete, IEnumerator<TSource>
		{
			internal TEnum mEnum;

			public this(TEnum items)
			{
				mEnum = items;
			}

			[SkipCall]
			public void Dispose() { }

		}

		extension Iterator<TEnum, TSource> : IDisposable where TEnum : IDisposable
		{
			public void Dispose() mut => mEnum.Dispose();
		}

		struct SelectEnumerator<TSource, TEnum, TSelect, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where TSelect : delegate TResult(TSource)
			where TEnum : concrete, IEnumerator<TSource>
		{
			TSelect mDlg;

			public this(TEnum e, TSelect dlg) : base(e)
			{
				mDlg = dlg;
			}

			public Result<TResult> GetNext() mut
			{
				if (mEnum.GetNext() case .Ok(let val))
					return mDlg(val);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static SelectEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TSelect, TResult>
			Select<TCollection, TSource, TSelect, TResult>(this TCollection items, TSelect select)
			where TCollection : concrete, IEnumerable<TSource>
			where TSelect : delegate TResult(TSource)
		{
			return .(items.GetEnumerator(), select);
		}


		struct WhereEnumerator<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
			where TEnum : concrete, IEnumerator<TSource>
		{
			TPredicate mPredicate;

			public this(TEnum enumerator, TPredicate predicate) : base(enumerator)
			{
				mPredicate = predicate;
			}

			public Result<TSource> GetNext() mut
			{
				while (mEnum.GetNext() case .Ok(let val))
					if (mPredicate(val))
						return .Ok(val);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static WhereEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			Where<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct TakeEnumerator<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
		{
			int mCount;

			public this(TEnum enumerator, int count) : base(enumerator)
			{
				mCount = count;
			}

			public Result<TSource> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static TakeEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Take<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}

		struct SkipEnumerator<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
		{
			int mCount;

			public this(TEnum enumerator, int count) : base (enumerator)
			{
				mCount = count;
			}

			public Result<TSource> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(?)) { }

				while (mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static SkipEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Skip<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}

		struct MapEnumerator<TSource, TEnum, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where bool : operator TSource < TSource
			where TSource : operator TSource - TSource
			where TResult : operator TResult + TResult
			where TResult : operator TResult - TResult
			where float : operator float / TSource
			where float : operator TSource * float
			where float : operator float / TResult
			where TResult : operator explicit float
			where TEnum : concrete, IEnumerator<TSource>
		{
			int mState = 0;
			float mScale = 0f, mMapScale;
			TSource mMin = default;
			TResult mMapMin;

			public this(TEnum enumerator, TResult mapMin, TResult mapMax) : base(enumerator)
			{
				mMapMin = mapMin;
				mMapScale = 1f / (mapMax - mapMin);
			}

			public Result<TResult> GetNext() mut
			{
				switch (mState) {
				case 0:
					var copyEnum = mEnum;
					switch (copyEnum.GetNext()) {
					case .Ok(let first):
						var min = first;
						var max = first;

						while (copyEnum.GetNext() case .Ok(let next))
						{
							if (next < min) min = next;
							if (max < next) max = next;
						}

						mMin = min;
						mScale = 1f / (max - min);
						if (mScale == default)
						{
							mState = 2;
							return .Ok(default);
						}

						mState = 1;
					case .Err: return .Err;
					}
					fallthrough;
				case 1:
					if (mEnum.GetNext() case .Ok(let val))
						return (TResult)(((val - mMin) * mScale) / mMapScale) + mMapMin;
				case 2:
					if (mEnum.GetNext() case .Ok(let val))
						return .Ok(default);
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static MapEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TResult>
			Map<TCollection, TSource, TResult>(this TCollection items, TResult min, TResult max)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
			where TSource : operator TSource - TSource
			where TResult : operator TResult + TResult
			where TResult : operator TResult - TResult
			where float : operator float / TSource
			where float : operator TSource * float
			where float : operator float / TResult
			where TResult : operator explicit float
		{
			return .(items.GetEnumerator(), min, max);
		}



		public static void ToList<T, TSource>(this T items, List<TSource> output)
			where T : concrete, IEnumerable<TSource>
		{
			for (var it in items)
				output.Add(it);
		}
	}
}
