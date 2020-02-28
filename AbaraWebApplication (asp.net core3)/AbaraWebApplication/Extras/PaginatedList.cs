using System;
using System.Collections.Generic;
using System.Linq;

namespace AbaraWebApplication.Extras
{
    public class PaginatedList<T> : List<T>
    {
        public int PageIndex { get; private set; }
        public int PageCount { get; private set; }
        public int PageLinkLeft { get; private set; }
        public int PageLinkStart { get; private set; }
        public int PageLinkEnd { get; private set; }
        public int PageLinkRight { get; private set; }

        public PaginatedList(IQueryable<T> source, int pageIndex = 1, int pageSize = 10, int pageLinkCount = 10)
        {
            if (pageIndex <= 0) pageIndex = 1;

            PageIndex = pageIndex;
            PageCount = Convert.ToInt32(Math.Ceiling(source.Count() / (double)pageSize));

            PageLinkStart = pageIndex - (pageIndex - 1) % pageLinkCount;
            PageLinkEnd = (PageLinkStart + pageLinkCount - 1);
            if (PageLinkEnd > PageCount) PageLinkEnd = PageCount;

            PageLinkLeft = (PageLinkStart > 1) ? PageLinkStart - pageLinkCount : -1;
            PageLinkRight = (PageCount > PageLinkEnd) ? PageLinkEnd + 1 : -1;

            this.AddRange(source.Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList());
        }
    }
}
