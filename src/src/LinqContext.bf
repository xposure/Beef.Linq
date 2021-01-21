using System.Collections;
using internal System.Linq;

namespace System.Linq
{
	public static
	{
		public static mixin From<TCollection, TSource>(TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			let from = scope:mixin LinqContext<decltype(default(TCollection).GetEnumerator()), TSource>(items.GetEnumerator());
			from
		}
	}

	public struct Disposables : IDisposable
	{
		[Ordered, Packed]
		private struct DisposableItem<T>
		{
			public function void(T* this) Func;
			public int16 Size;
			public T Data;
		}

		[Ordered, Packed]
		private struct DisposableItem
		{
			public function bool(void* this) Func;
			public int16 Size;
			public void* Data;
		}

		private int _count = 0;
		private List<uint64> _data = new .(1024);

		public void Dispose() mut
		{
			var ptr = _data.Ptr;
			for (var i < _count)
			{
				var script = (DisposableItem*)ptr;

				script.Func(&script.Data);
				ptr += script.Size;
			}

			DeleteAndNullify!(_data);
		}

		private T* InternalAdd<T>(T t, function void(T* this) k) mut
			where T : struct
		{
			let SIZE = (strideof(DisposableItem<T>) + sizeof(uint64) * 2) / sizeof(uint64) - 1;
			var ptr = (DisposableItem<T>*)_data.GrowUnitialized(SIZE);
			ptr.Size = SIZE;
			ptr.Func = k;
			ptr.Data = t;
			_count++;

			return &ptr.Data;
		}

		public T* Add<T>(T t) mut
			where T : var, IDisposable
		{
			return InternalAdd(t, => t.Dispose);
		}
	}

	struct DynamicArray<TValue> :  IDisposable
	{
		TValue[] mPtr = default;
		Span<TValue> mSpan = default;
		int mLength = 0;
		int mSize = 4;
		int mIndex = 0;

		public int Length => mLength;

		public this()
		{
			this.mPtr = new TValue[mSize];
			this.mLength = 0;
		}

		public ref TValue this[int index] => ref mPtr[index];

		public void Dispose() mut
		{
			DeleteAndNullify!(mPtr);
			mPtr = null;
		}

		public void Add(TValue value) mut
		{
			if (mLength + 1 > mSize)
			{
				var newSize = mSize * 3 / 2;
				var dst  = new TValue[newSize];
				Array.Copy(mPtr, dst, mLength);
				Swap!(mPtr, dst);
				delete dst;
			}
			mPtr[mLength++] = value;
		}

		public Span<TValue>.Enumerator GetEnumerator() mut
		{
			mSpan = .(mPtr, 0, mLength);
			return mSpan.GetEnumerator();
		}

	}

	public struct Grouping<TKey, TValue> : IEnumerable<TValue>, IEnumerator<TValue>
	{
		DynamicArray<TValue>* mValues;
		int mIndex = 0;
		public readonly TKey Key;

		public this(TKey key, DynamicArray<TValue>* values)
		{
			Key = key;
			mValues = values;
		}

		public Result<TValue> GetNext() mut
		{
			if (mIndex == mValues.Length)
				return .Err;

			return .Ok((*mValues)[mIndex++]);
		}

		public Self GetEnumerator()
		{
			return this;
		}

		public void Add(TValue value) mut
		{
			mValues.Add(value);
		}
	}

	public struct GroupByEnumerable<TSource, TEnum, TKey, TKeyDlg> :
		IEnumerator<Grouping<TKey, TSource>>, IEnumerable<Grouping<TKey, TSource>>, IDisposable

		where TEnum : concrete, IEnumerator<TSource>
		where bool : operator TKey == TKey//where TKey : IHashable
		where TKeyDlg : delegate TKey(TSource)
	{
		LinqContext<TEnum, TSource> mContext;
		DynamicArray<Grouping<TKey, TSource>>* mResults = default;
		TKeyDlg mKeyDlg;
		Iterator<TEnum, TSource> mIterator;
		int mIndex = -1;

		public this(LinqContext<TEnum, TSource> context, TEnum enumerator, TKeyDlg keyDlg)
		{
			mContext = context;
			mIterator = .(enumerator);
			mKeyDlg = keyDlg;
		}

		public Result<Grouping<TKey, TSource>> GetNext() mut
		{
			if (mIndex == -1)
			{
				mResults = mContext.mDisposables.Add( DynamicArray<Grouping<TKey, TSource>>());
				while (mIterator.mEnum.GetNext() case .Ok(let val))
				{
					let key = mKeyDlg(val);
					var added = false;
					for (var it in ref *mResults)
					{
						if (it.Key == key)
						{
							it.Add(val);
							added = true;
						}
					}

					if (!added){
						var group = mResults.Add(.. .(key, mContext.mDisposables.Add(DynamicArray<TSource>())));
						group.Add(val);
					}
				}
				mIndex = 0;
			}

			if(mIndex <  mResults.Length)
				return (*mResults)[mIndex++];

			return .Err;
		}

		public Self GetEnumerator()
		{
			return this;
		}

		public void Dispose() mut
		{
			mIterator.Dispose();
		}
	}

	public class LinqContext<TEnum, TSource>
		where TEnum : concrete, IEnumerator<TSource>
	{
		internal Disposables mDisposables = .() ~ _.Dispose();
		internal TEnum mEnum;

		public this(TEnum enumerator)
		{
			mEnum = enumerator;
		}

		public GroupByEnumerable<TSource, TEnum, TKey, TKeyDlg>
			GroupBy<TKey, TKeyDlg>(TKeyDlg key)
			where TKeyDlg : delegate TKey(TSource)
			where TKey : IHashable
		{
			return .(this, mEnum, key);
		}
	}
}
