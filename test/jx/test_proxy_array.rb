# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2016 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'rubygems'
require "test/unit"
require 'shoulda'

require '../../config' if @platform == nil
require 'mdarray-sol'


class MDArraySolTest < Test::Unit::TestCase

  context "B environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end
        
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "inject and retrieve back the same ruby objects" do

      a1 = [1, 2, 3]
      B.p1 = a1

      # extracts back the B.p1 variable.  It will be a ruby object
      p "extracting b1"
      b1 = B.p1
      p b1
      
      assert_equal(2, b1[1])
      p b1.concat([4, 5, 6])
      p b1[3]
      p [-1, -2, -3].concat(b1)
      
    end
        
#=begin    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy flat ruby array" do

      a1 = [1, 2, 3]
      a2 = [4, 5]
      
      B.p1 = a1
      B.p2 = a2

      B.eval(<<-EOT)
        var assert = chai.assert;

        // use ruby method concat
        p1.concat(p2);

        // Check that proxied arrays share the same data as the original ruby arrays
        assert.equal(2, p1[1]);
        assert.equal(5, p1[4]);
        assert.equal(5, p2[1]);
        assert.equal(5, p1.length);

        // should also allow negative indices for array access
        assert.equal(5, p1[-1]);
        assert.equal(2, p1[-4]);

      EOT

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy nested arrays and hashes" do

      a1 = [{name: "John", "age" => 25}, {name: "Mary", "age" => 30},
            {name: "Paul", "age" => 18}, {name: "Anton", "age" => 45}]

      B.data = a1

      B.eval(<<-EOT)
        var assert = chai.assert;

        assert.equal("John", data[0].fetch("name"));
        assert.equal(25, data[0].age);
        assert.equal("Anton", data[3].fetch("name"));
        assert.equal(18, data[2].age);
      EOT

    end
        
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "Allow access directly from a js file" do
      
      B.data = [1, 2, 3, 4]
      B.d2 = [10, 20, 30, 40, 50, 60]
      
      # load a javascript file to test arrays.  assert clauses in the javascript file
      # will not be shown as tests, unfortunately.
      B.load("test_ruby_array.js")
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow array updates" do

      a1 = [1, 2, 3]

      # B.p1 is a javascript object that proxies the a1 ruby array
      B.p1 = a1

      assert_equal(1, B.p1[0])

      # assing a value to an array index
      B.p1[3] = 4
      assert_equal(4, B.p1[3])

      B.eval(<<-EOT)
        var assert = chai.assert;
        assert.equal(4, p1[3]);
        p1[5] = 5
        console.log(p1.to_s());        
      EOT
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "call ruby methods passing javascript functions as blocks" do

      a1 = [1, 2, 3, 4, 5]

      B.p1 = a1
      
      B.eval(<<-EOT)

        var assert = chai.assert;
        // call ruby functions on the array, including functions that require a block
        // or have names that do not exist in javascript
        console.log("should output values 1 to 5 in javascript output");
        p1.each(function(x) { console.log(x); });

      EOT
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "call ruby methods with invalid javascript names" do

      a1 = [1, 2, 3]
      a2 = [4, 5]
      
      # p1 and p2 are proxy elements for arrays a1 and a2.  They will work as array
      # in ruby
      B.p1 = a1
      B.p2 = a2
      
      B.eval(<<-EOT)
        var assert = chai.assert;

        p1.concat(p2);
        console.log(p1.to_s());

        // Concate two arrays going element by element.  Better use ruby´s concat
        // method... just an example of using a function as block for the each
        // method and the use of a method with a name not valid in javascript
        p2.each(function(x) { p1.send("<<", x); });
        console.log(p1.to_s());

      EOT
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy a ruby arrays" do

      a1 = [1, 2, 3]

      B.p1 = a1

      B.eval(<<-EOT)
        var assert = chai.assert;

        // val is a proxied Ruby object
        var val = p1.map(function(x) { return x; });

        // val can be inspected by calling method to_s()
        assert.equal('[1.0, 2.0, 3.0]', val.to_s());

        // Note that each_with_index is a Ruby array method that accepts a block.
        // Here we pass a javascript function in place of a block.
        var cumSum = 0;
        p1.each_with_index(function(x, i) {
          if (i % 2 == 0) {
            cumSum = cumSum + x;
          }
        });
        assert.equal(4, cumSum);
        
      EOT

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy nested ruby arrays" do
      
      a3 = [[1, 2], [3, 4], [5, 6, [7, [8, 9]]]]
      
      B.p3 = a3

      B.eval(<<-EOT)
        var assert = chai.assert;
        
        var val = p3.map(function(x) { return x; });
        assert.equal(1, val[0][0]);
        assert.equal(3, val[1][0]);
        assert.equal(6, val[2][1]);
        assert.equal(7, val[2][2][0]);
        assert.equal(9, val[2][2][1][1]);

      EOT

    end
#=end
    
  end
  
end
