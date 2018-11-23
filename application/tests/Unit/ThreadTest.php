<?php

namespace Tests\Unit;

use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use App\Thread;
use Illuminate\Database\Eloquent\Collection;
use App\User;

class ThreadTest extends TestCase
{
    use DatabaseMigrations;

    public function setUp()
    {
        parent::setUp();

        $this->thread = factory(Thread::class)->create();
    }

    public function testHasReplies()
    {
        $this->assertInstanceOf(Collection::class, $this->thread->replies);
    }

    public function testHasACreator()
    {
        $this->assertInstanceOf(User::class, $this->thread->creator);
    }

    public function testAddReply()
    {
        $this->thread->addReply([
            'body' => 'Testing add reply',
            'user_id' => factory(User::class)->create()->id,
        ]);

        $this->assertCount(1, $this->thread->replies);
    }
}
