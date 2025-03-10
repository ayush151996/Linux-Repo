// { dg-do run { target c++17 } }

// Copyright (C) 2013-2025 Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License along
// with this library; see the file COPYING3.  If not see
// <http://www.gnu.org/licenses/>.

// basic_string_view constructors.

#include <string_view>
#if __STDC_HOSTED__
# include <string>
#endif // HOSTED
#include <cwchar>
#include <testsuite_hooks.h>

void
test01()
{
  typedef std::wstring_view::size_type csize_type;

  // basic_string_view()
  const std::wstring_view str00{};
  VERIFY( str00.length() == 0 );
  VERIFY( str00.data() == nullptr );

  // basic_string_view(const char*)
  const wchar_t str_lit01[] = L"rodeo beach, marin";
  const std::wstring_view str01{str_lit01};
  VERIFY( str01.length() == 18 );
  VERIFY( str01.data() == str_lit01 );
  const std::wstring_view str02{L"baker beach, san francisco"};
  VERIFY( str02.length() == 26 );

  // basic_string_view(const string_view&)
  std::wstring_view str04{str01};
  VERIFY( str04.length() == str01.length() );
  VERIFY( str04.data() == str01.data() );

  // basic_string_view(const char* s)
  csize_type len_lit01 = wcslen(str_lit01);
  std::wstring_view str05{str_lit01, len_lit01};
  VERIFY( str05.length() == len_lit01 );
  VERIFY( str05.data() == str_lit01 );

#if __STDC_HOSTED__
  // basic_string_view(basic_string& s)
  std::wstring istr07(10, L'z');
  std::wstring_view str07{istr07};
  VERIFY( str07.length() == 10 );
#endif // HOSTED
}

int
main()
{ 
  test01();

  return 0;
}
