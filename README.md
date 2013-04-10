About
=====

SuperStacker is a tool for writing cloudformation templates in a ruby DSL.

The DSL is parsed and then output as JSON, ready for use with the
CloudFormation toolchain.

Syntax
======

We will go through basic syntax and language constructs here. Knowledge of
CloudFormation templates and basic Ruby knowledge is assumed.

description
-----------

The description for a cloudformation stack is specified using the `description`
keyword, as shown below:

`description "description for this stack"`

See [AWS documentation][1] for further information.

[1]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-description-structure.html

parameter
---------

A parameter to be passed through to the CloudFormation template during stack
creation time.

`parameter "ParameterName", "Type" => "String", "AllowedValues" => ["value1", "value2"]`

The parameter keyword knows how to handle all of the properties specified in the
[AWS documentation][2]. Please consult that for information on accepted
properties.

[2]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html

resource
--------

A resource is a nice clean interface for building a Hash. This is probably best
explained as an example:

resource "TestName", "MyFakeType" do
  Key "Value"
  NestedHash do
    NestedKey "NestedValue"
  end
end

would become

{
  "TestName" => {
    "Type" => "MyFakeType",
    "Key" => "Value",
    "NestedHash" => {
      "NestedKey" => "NestedValue"
    }
  }
}

Resources should be able to represent any of the resources available in AWS.
Please consult the [AWS Documentation][3] for a complete list of available
resources, types and properties.

[3]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html

Ref
---

Ref is used to create a reference to another element of the CloudFormation
template, is is essentially shorthand for the (rather verbose) JSON syntax.

`Ref("SomeElement")`
=> { "Ref" => "SomeElement" }

Examples
========

Example stacks have been included in the exampes/ directory. Please consult
them for practical use cases. I'll be updating this directory with more examples
as I add features so check back regularly.

To check the output of a sample do something like:

`super-stacker stack examples/ec2-instance/`
