<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use App\Reply;
use App\User;

class ReplyTest extends TestCase
{
    use DatabaseMigrations;

    public function testHasAnOwner()
    {
        $reply = factory(Reply::class)->create();
        $this->assertInstanceOf(User::class, $reply->owner);
    }
}
